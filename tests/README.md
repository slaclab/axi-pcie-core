# RTL Regression Tests

`pytest` + `cocotb` + GHDL + ruckus regressions for the RTL in this repository,
following the same flow as the [surf](https://github.com/slaclab/surf) regressions.
No Vivado installation is needed. CI runs them in the `RTL Regression Tests` job of
`.github/workflows/axi_ci.yml`.

## Running Locally

Requirements: GHDL, `tclsh`, `make`, the Python packages in `pip_requirements.txt`,
and checkouts of [ruckus](https://github.com/slaclab/ruckus) and
[surf](https://github.com/slaclab/surf) in one directory (`MODULES`). When this
repository is checked out as a submodule next to them, `MODULES` defaults to the
parent directory.

```bash
# Import the HDL sources into build/SRC_VHDL (rerun after a source-list change)
make MODULES=<dir with ruckus and surf> import

# Whole regression, test modules in parallel, simulator log printed at the end
python -m pytest -v -rA -n auto --dist=worksteal tests/

# One test module, serial, with the live simulator log
python -m pytest -n 0 --log-cli-level=INFO tests/hardware/XilinxVariumC1100/test_HbmDmaBufferV2.py

# One cocotb scenario of that module
COCOTB_TEST_FILTER=stall_mid_burst python -m pytest -n 0 --log-cli-level=INFO tests/hardware/XilinxVariumC1100/test_HbmDmaBufferV2.py
```

Each test module is one simulation that runs its cocotb scenarios one after the
other. The pytest result is the result of the whole simulation; the cocotb summary
table in the simulator log has the result of each scenario.

Simulation build directories are written to `tests/sim_build/`.

## Layout

- `ruckus.tcl` and `Makefile` at the top of the repository are the GHDL source
  manifest and its `make` entry point. They list only RTL that simulates without
  vendor IP, plus the simulation models that stand in for it. Vivado projects
  keep loading `hardware/<board>/ruckus.tcl`.
- `tests/common/regression_utils.py` is the shared launcher (`run_vhdl_test()`).
- Test modules mirror the source tree, for example
  `tests/hardware/XilinxVariumC1100/test_HbmDmaBufferV2.py`.
- The cocotb-facing VHDL top-levels and vendor IP models live beside the RTL in
  the board's `tb/` directory.

## Vendor IP Models

GHDL cannot simulate Xilinx primitives or encrypted IP, so each one in the path of
a test needs a VHDL stand-in that is loaded by the top-level `ruckus.tcl`:

| Replaced | Model | How it is bound |
|---|---|---|
| `HbmDmaBufferV2IpCore` (Xilinx HBM IP) | `hardware/XilinxVariumC1100/tb/HbmDmaBufferV2IpCore.vhd` | Same entity name and ports as the component declaration (default binding) |
| `surf.ClockManagerUltraScale` (MMCM) | `hardware/XilinxVariumC1100/tb/ClockManagerUltraScaleSim.vhd` | Compiled into the `surf` library; the surf GHDL import does not provide this entity |
| XPM FIFOs | surf inferred FIFOs | `SYNTH_MODE_G => "inferred"` on the DUT |

## Known-Bug Scenarios

A cocotb scenario that reproduces an open issue is marked `@cocotb.xfail` with the
issue link. cocotb then expects it to fail on an assertion: the simulator log
reports it as `passed: failed as expected` together with the assertion message, so
CI stays green while the bug is open. As soon as the scenario passes, cocotb
reports `failed: passed but we expected a failure` and the pytest test fails. The
change that fixes the bug removes the marker.
