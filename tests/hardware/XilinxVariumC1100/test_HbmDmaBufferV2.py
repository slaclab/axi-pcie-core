#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

# Test methodology:
# - DUT: The unmodified HbmDmaBufferV2 (both DMA lanes) inside the flat-port
#   HbmDmaBufferV2Tb wrapper. The Xilinx HBM IP and the MMCM wrapper are replaced
#   by the VHDL models in hardware/XilinxVariumC1100/tb/, and the DMA FIFO
#   queues are inferred instead of XPM. Everything else is the shipping RTL
#   with the shipping generics.
# - Datapath: Frames go in on S_AXISn (64B words), are written to the HBM model
#   through the IbFifo, AxiStreamDmaV2Fifo and HbmDmaBufferV2AxiSplit, are read
#   back, and come out on M_AXISn. Both lanes run the same scenario at the same
#   time with different payloads; the HBM model is one memory shared by all
#   four AXI ports, so cross-lane or cross-port aliasing corrupts data.
# - Stimulus: Each scenario controls where the gaps in the inbound stream land,
#   because that decides whether AxiStreamDmaV2Write ends a write burst early
#   (pad beats) and restarts it off a BURST_BYTES_G (1kB) boundary:
#     * the DMA pads a burst after 100 idle hbmClk cycles in the middle of it;
#     * the IbFifo hands the DMA 8 words (512B) at a time, so an input slower
#       than about 512B per 100 hbmClk cycles (~12 Gb/s) stalls mid-burst with
#       no gap at the source;
#     * a TDEST change in the middle of a burst pads it as well.
# - Check: Every frame must come out once, byte-for-byte identical, with its
#   TDEST. Every frame ends in a partial 64B word to cover the byte count.
# - One simulation: After reset the DMA FIFO takes 13.7 us to load its free
#   list, which is most of a scenario's run time, so all scenarios share one
#   simulation and only the first one resets the DUT. A scenario therefore
#   drains every frame it sent on both lanes before it asserts anything, so a
#   failing scenario leaves the DUT idle for the next one. Each frame gets a
#   buffer that no earlier frame used (the free list is a 4096 deep queue).
# - Issue 245: stall_mid_burst, steady_rate_slow and tdest_interleave restart a
#   write burst off a 1kB boundary. They read back corrupted frames unless
#   HbmDmaBufferV2AxiSplit maps the DMA byte address onto the 32B wide HBM ports
#   correctly (https://github.com/slaclab/axi-pcie-core/issues/245).
# - Not covered: back-pressure from the HBM ports (the model always accepts),
#   the AXI-Lite registers, and anything inside the Xilinx HBM IP.

import logging
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer, with_timeout
from cocotbext.axi import AxiStreamBus, AxiStreamSink

from tests.common.regression_utils import run_vhdl_test

NUM_LANES    = 2
WORD_BYTES   = 64   # Stream word and DMA AXI beat
LAST_BYTES   = 37   # Valid bytes in the last word of every frame
STALL_CYCLES = 150  # axisClk cycles (600 ns), longer than 100 hbmClk cycles (333 ns)

# After reset the DMA FIFO loads its 4096 entry free list at one entry per
# hbmClk cycle (13.7 us). Traffic sent before that only waits, but then the
# gaps in the stimulus would not land where a scenario wants them.
INIT_TIME_US = 16

# Set by the first scenario of a simulation, which is the only one that resets the DUT
_dut_is_initialized = False

RX_TIMEOUT_US = 100


class StreamDriver:
    """Drives one S_AXISn port word by word so idle gaps land on exact word boundaries."""

    def __init__(self, dut, lane):
        prefix      = f"S_AXIS{lane}"
        self.clk    = dut.axisClk
        self.tvalid = getattr(dut, f"{prefix}_TVALID")
        self.tdata  = getattr(dut, f"{prefix}_TDATA")
        self.tkeep  = getattr(dut, f"{prefix}_TKEEP")
        self.tlast  = getattr(dut, f"{prefix}_TLAST")
        self.tdest  = getattr(dut, f"{prefix}_TDEST")
        self.tready = getattr(dut, f"{prefix}_TREADY")
        for signal in (self.tvalid, self.tdata, self.tkeep, self.tlast, self.tdest):
            signal.value = 0

    async def send(self, dest, data, *, last, idle=0):
        """Send `data` as consecutive 64B words, with `idle` clock cycles after each word.

        TLAST is set on the final word when `last` is true. Only the final word
        of a frame may be shorter than 64 bytes.
        """
        for offset in range(0, len(data), WORD_BYTES):
            chunk = data[offset:offset + WORD_BYTES]
            self.tdata.value  = int.from_bytes(chunk, "little")
            self.tkeep.value  = (1 << len(chunk)) - 1
            self.tlast.value  = int(last and (offset + WORD_BYTES >= len(data)))
            self.tdest.value  = dest
            self.tvalid.value = 1
            while True:
                await RisingEdge(self.clk)
                if self.tready.value == 1:
                    break
            if idle:
                self.tvalid.value = 0
                await ClockCycles(self.clk, idle)
        self.tvalid.value = 0


class TB:
    def __init__(self, dut):
        self.dut = dut
        Clock(dut.userClk, 10, unit="ns").start()  # 100 MHz MMCM and HBM reference
        self.axis_clock = Clock(dut.axisClk, 4, unit="ns")  # 250 MHz x 64B = 128 Gb/s back-to-back
        self.axis_clock.start()
        self.drivers = [StreamDriver(dut, lane) for lane in range(NUM_LANES)]
        self.sinks   = [
            AxiStreamSink(AxiStreamBus.from_prefix(dut, f"M_AXIS{lane}"), dut.axisClk, dut.axisRst)
            for lane in range(NUM_LANES)
        ]
        for sink in self.sinks:
            sink.log.setLevel(logging.WARNING)  # Do not log the payload of every frame

    async def start(self):
        """Reset the DUT and wait for its initialization, the first time in a simulation only."""
        global _dut_is_initialized
        if not _dut_is_initialized:
            self.dut.axisRst.value = 1
            await ClockCycles(self.dut.axisClk, 32)
            self.dut.axisRst.value = 0
            # Let the resets propagate, then pause the stream clock while the
            # free list loads: nothing in that clock domain has work to do, and
            # simulating it idle costs more than the HBM clock domain itself.
            await ClockCycles(self.dut.axisClk, 64)
            self.axis_clock.stop()
            await Timer(INIT_TIME_US, unit="us")
            self.axis_clock.start()
            _dut_is_initialized = True
        await ClockCycles(self.dut.axisClk, 4)

    async def receive(self, lane, count):
        """Receive `count` frames of one lane as {tdest: [frame, ...]} without checking them."""
        received = {}
        for _ in range(count):
            frame = await with_timeout(self.sinks[lane].recv(), RX_TIMEOUT_US, "us")
            received.setdefault(frame.tdest, []).append(bytes(frame.tdata))
        return received


def _compare(lane, received, expected):
    """Compare the frames of one lane. Both arguments are {tdest: [frame, ...]}."""
    assert set(received) == set(expected), (
        f"lane {lane}: received TDEST {sorted(received)}, expected {sorted(expected)}"
    )
    for dest, frames in expected.items():
        assert len(received[dest]) == len(frames), (
            f"lane {lane} TDEST {dest}: received {len(received[dest])} frames, expected {len(frames)}"
        )
        for index, (got, exp) in enumerate(zip(received[dest], frames)):
            assert got == exp, _describe_mismatch(lane, dest, index, got, exp)


def _describe_mismatch(lane, dest, index, got, exp):
    where = f"lane {lane} TDEST {dest} frame {index}"
    if len(got) != len(exp):
        return f"{where}: {len(got)} bytes received, expected {len(exp)}"
    bad = [
        offset // WORD_BYTES
        for offset in range(0, len(exp), WORD_BYTES)
        if got[offset:offset + WORD_BYTES] != exp[offset:offset + WORD_BYTES]
    ]
    words = -(-len(exp) // WORD_BYTES)
    return f"{where}: {len(bad)} of {words} 64B words corrupted, first bad word is {bad[0]}"


def _frame(rng, words):
    return rng.randbytes((words - 1) * WORD_BYTES + LAST_BYTES)


async def _run(dut, stimulus):
    """Run `stimulus(driver, rng)` on both lanes at once, then check both lanes.

    The stimulus coroutine returns the frames it sent as {tdest: [frame, ...]}.
    """
    tb = TB(dut)
    await tb.start()
    senders = [
        cocotb.start_soon(stimulus(tb.drivers[lane], random.Random(f"{stimulus.__name__}-{lane}")))
        for lane in range(NUM_LANES)
    ]
    expected = [await sender for sender in senders]

    # Drain both lanes before the first assertion: the next scenario reuses the DUT
    received = [
        await tb.receive(lane, sum(len(frames) for frames in expected[lane].values()))
        for lane in range(NUM_LANES)
    ]
    for lane in range(NUM_LANES):
        _compare(lane, received[lane], expected[lane])


async def _stall(drv, rng, words_before_stall):
    """One 4kB frame with a single gap at the source after `words_before_stall` words."""
    data = _frame(rng, 64)
    cut  = words_before_stall * WORD_BYTES
    await drv.send(0, data[:cut], last=False)
    await ClockCycles(drv.clk, STALL_CYCLES)
    await drv.send(0, data[cut:], last=True)
    return {0: [data]}


async def _steady_rate(drv, rng, idle):
    """One 4kB frame at a constant rate of one 64B word every `idle + 1` clock cycles."""
    data = _frame(rng, 64)
    await drv.send(0, data, last=True, idle=idle)
    return {0: [data]}


@cocotb.test(timeout_time=300, timeout_unit="us")
async def back_to_back(dut):
    """Frames of assorted lengths with no gaps: every write burst starts on a 1kB boundary."""
    async def stimulus(drv, rng):
        frames = [_frame(rng, words) for words in (1, 8, 16, 17, 64, 100)]
        for data in frames:
            await drv.send(0, data, last=True)
        return {0: frames}

    await _run(dut, stimulus)


@cocotb.test(timeout_time=300, timeout_unit="us")
async def stall_mid_burst(dut):
    """Source pauses after 16 words: the IbFifo holds back 8, so the DMA stalls after word 7 and pads."""
    async def stimulus(drv, rng):
        return await _stall(drv, rng, 16)

    await _run(dut, stimulus)


@cocotb.test(timeout_time=300, timeout_unit="us")
async def stall_on_burst_boundary(dut):
    """Source pauses after 24 words: the DMA stalls after word 15, between bursts, so nothing is padded."""
    async def stimulus(drv, rng):
        return await _stall(drv, rng, 24)

    await _run(dut, stimulus)


@cocotb.test(timeout_time=300, timeout_unit="us")
async def steady_rate_slow(dut):
    """No gap at the source, 64B every 13 cycles (9.8 Gb/s): too slow to fill a burst before the DMA pads."""
    async def stimulus(drv, rng):
        return await _steady_rate(drv, rng, 12)

    await _run(dut, stimulus)


@cocotb.test(timeout_time=300, timeout_unit="us")
async def steady_rate_fast(dut):
    """No gap at the source, 64B every 6 cycles (21 Gb/s): fast enough that the DMA never pads."""
    async def stimulus(drv, rng):
        return await _steady_rate(drv, rng, 5)

    await _run(dut, stimulus)


@cocotb.test(timeout_time=300, timeout_unit="us")
async def tdest_interleave(dut):
    """Two TDEST interleaved in 5 word chunks with no gaps: every TDEST change pads the open burst."""
    async def stimulus(drv, rng):
        chunk_bytes = 5 * WORD_BYTES
        frames = {1: [], 2: []}
        for _ in range(2):
            pair = {dest: _frame(rng, 40) for dest in frames}
            for chunk in range(8):
                for dest, data in pair.items():
                    await drv.send(dest, data[chunk * chunk_bytes:(chunk + 1) * chunk_bytes], last=(chunk == 7))
            for dest, data in pair.items():
                frames[dest].append(data)
        return frames

    await _run(dut, stimulus)


def test_HbmDmaBufferV2():
    # One simulation runs every cocotb scenario above, in the order they are defined
    run_vhdl_test(
        test_file=__file__,
        toplevel="axi_pcie_core.hbmdmabufferv2tb",
        # Until the first word arrives, the DMA converts the undefined output of
        # the empty IbFifo to an integer on every clock: tens of thousands of
        # std_logic_arith metavalue warnings that say nothing about the DUT
        sim_args=["--ieee-asserts=disable"],
    )
