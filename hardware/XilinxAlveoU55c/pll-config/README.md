# Alveo U55C Si5394 PLL Configurations

Register images for the Skyworks/SiLabs **Si5394B-A11828-GMR** jitter attenuator on the
Xilinx Alveo U55C. The firmware loads one of these images into the device over I2C at
power-up so that the QSFP GT reference clocks come up at the frequency the application
needs, instead of the 161.1328125 MHz that the factory NVM provides.

The same files are also used by the Varium C1100 target (`hardware/XilinxVariumC1100`).

## Files

| Base name (`.csv` and `.mem`)          | OUT0 (QSFP0 GT refclk) | OUT1 (QSFP1 GT refclk) | OUT2 / OUT3 (system clocks) |
|----------------------------------------|------------------------|------------------------|-----------------------------|
| `Si5394A_GT_REFCLK_156MHz`             | 156.25 MHz             | 156.25 MHz             | 100 MHz                     |
| `Si5394A_GT_REFCLK_161MHz`             | 161.1328125 MHz        | 161.1328125 MHz        | 100 MHz                     |
| `Si5394A_GT_REFCLK_156MHz_LCLS-II`     | 156.25 MHz             | 185.7142857 MHz        | 100 MHz                     |
| `Si5394A_GT_REFCLK_156MHz_LCLS-I`      | 156.25 MHz             | 119 MHz                | 100 MHz                     |

All four images share the same VCO, N0 (100 MHz) and output-driver settings. They differ
only in a handful of divider registers:

- `Si5394A_GT_REFCLK_156MHz`: for 10GBASE-R / 25GBASE-R PHYs and PGP links that expect a
  156.25 MHz reference (10.3125 Gb/s = 156.25 MHz x 66). This is the default
  `SI5394_INIT_FILE_G` in `XilinxAlveoU55cCore.vhd`. OUT0 and OUT1 both come from N1.
- `Si5394A_GT_REFCLK_161MHz`: reproduces the board's factory default reference
  (10.3125 Gb/s = 161.1328125 MHz x 64), for designs that were built against the stock
  U55C clocking. Differs from the 156 MHz image only in the N1 denominator
  (`0x0314..0x0316`).
- `Si5394A_GT_REFCLK_156MHz_LCLS-II`: OUT0 stays at 156.25 MHz; OUT1 moves to the
  otherwise unused N2 divider and generates the LCLS-II timing reference
  1300 MHz / 7 = 185.714285714 MHz (exact). Relative to the 156 MHz image: OUT1 mux
  (`0x011A`), OUT1 `RDIV_FORCE2` (`0x0117`) and R register (`0x0253`), N2 numerator and
  denominator (`0x0318..0x0321`), and the N2 enables (`0x0A03`, `0x0A05`, `0x0B4A`).
- `Si5394A_GT_REFCLK_156MHz_LCLS-I`: OUT0 stays at 156.25 MHz; OUT1 moves to N2 and
  generates the LCLS-I timing reference 119 MHz (exact). Same register set as LCLS-II
  except that OUT1 keeps R = 4, so `0x0117` and `0x0253` are unchanged.

## Board clock tree

From the U55C master XDC (`U55C_xdc_1v00.xdc`) and UG1469. Note that the clock-tree figure
in UG1469 omits OUT3; AMD support has confirmed the XDC is correct and that there are four
outputs.

```
40 MHz TCXO ---> XA/XB (external clock mode)
                   |
   Si5394B-A11828  |-> OUT0  SYNCE_CLK0   QSFP0 MGTREFCLK0_130  AD42/AD43   (qsfp0RefClkP/N)
   I2C addr 0x68   |-> OUT1  SYNCE_CLK1   QSFP1 MGTREFCLK0_131  AB42/AB43   (qsfp1RefClkP/N)
                   |-> OUT2  Si53306 1:4 buffer
                   |            |-> PCIE_SYSCLK0  MGTREFCLK1_227  AK13/AK12
                   |            |-> PCIE_SYSCLK1  MGTREFCLK1_225  AP13/AP12
                   |            |-> SYSCLK2       bank 68         BK10/BL10   (userClkP/N)
                   |            |-> SYSCLK3       bank 65         BK43/BK44   (hbmRefClkP/N)
                   |-> OUT3  Si53306 1:4 buffer
                                |-> SYSCLK4       bank 72         F24/F23
                                |-> NS2_SYSCLK6   MGTREFCLK1_125  AP42/AP43
                                |-> NS1_SYSCLK5   MGTREFCLK1_127  AK42/AK43
```

OUT2 and OUT3 must stay at 100 MHz: they feed the 100 MHz `userClk` and `hbmRefClk`
inputs used by this core, and (via the Si53306 buffers) the PCIe SYSCLK references. Only
OUT0/OUT1 differ between the images.

The PCIe link itself uses `pciRefClk` from the edge connector (AL15/AL14 and AR15/AR14),
which is independent of the Si5394. This is what allows the firmware to reprogram the
Si5394 at boot without disturbing the PCIe link.

## Decoded frequency plan

Register fields decoded from the CSV using the Si5395/94/92 Family Reference Manual
layout (the datasheet itself only describes the page structure and defers to the RM).

| Block             | Registers               | Value                               | Result                           |
|-------------------|-------------------------|-------------------------------------|----------------------------------|
| XA/XB input       | `0x090E` = 0x03         | `XAXB_EXTCLK_EN` = 1                | 40 MHz TCXO, external clock mode |
| PXAXB prescaler   | `0x0206` = 0x00         | divide by 1                         | 40 MHz to PLL                    |
| MXAXB (free-run)  | `0x0235..0x023E`        | 0xA5 << 32 / 2^31 = 330             | fVCO = 40 MHz x 330 = 13.2 GHz   |
| Clock inputs      | `0x0949`, `0x094A` = 0  | `IN_EN` = 0, P0..P3 = 0, LOS/OOF off | IN0..IN3 unused, free-run only  |
| M feedback        | `0x0515..0x051F` = 0    | unused                              | (no input to lock to)            |
| N0 (integer)      | `0x0302..0x030B`        | 0x21 << 32 / 2^31 = 66              | 13.2 GHz / 66 = 200 MHz          |
| N1 (fractional)   | `0x030D..0x0316`        | 156: 2^36 / 0xC1F07C00 = 21.12      | 13.2 GHz / 21.12 = 625 MHz       |
|                   |                         | 161: 2^36 / 0xC8000000 = 20.48      | 13.2 GHz / 20.48 = 644.53125 MHz |
| N2 (fractional)   | `0x0318..0x0321`        | LCLS-II: 462/13 = 35.538461538 (scaled by 2^28) | 13.2 GHz / N2 = 371.428571 MHz |
|                   |                         | LCLS-I: 3300/119 = 27.731092437 (scaled by 2^25) | 13.2 GHz / N2 = 476 MHz       |
|                   |                         | 156 / 161 images: 0 (unused)        |                                  |
| OUT0              | `0x0112..0x0115`        | mux = N1, R = 4 (`0x0250` = 1)      | 156.25 or 161.1328125 MHz        |
| OUT1              | `0x0117..0x011A`        | 156 / 161: mux = N1, R = 4 (`0x0253` = 1) | 156.25 or 161.1328125 MHz  |
|                   |                         | LCLS-II: mux = N2, `RDIV_FORCE2` = 1 (R = 2) | 185.714285714 MHz       |
|                   |                         | LCLS-I: mux = N2, R = 4 (`0x0253` = 1) | 119 MHz                       |
| OUT2, OUT3        | `0x0126..0x012E`        | mux = N0, `RDIV_FORCE2` = 1 (R = 2) | 100 MHz                          |
| N divider enables | `0x0A03`, `0x0A05`, `0x0B4A` | 156 / 161: 0x03, 0x03, 0x0C (N0, N1 on) | |
|                   |                         | LCLS-I / LCLS-II: 0x07, 0x07, 0x08 (N0, N1, N2 on) | |

N1 = 528/25 (156.25 MHz) or 512/25 (161.1328125 MHz). ClockBuilder Pro scales the
numerator to 2^36 and rounds the 32-bit denominator, so the 156.25 MHz plan carries a
residual error of about -10 ppb; the 161.1328125 MHz and 100 MHz plans are exact.

The LCLS N2 ratios were chosen so that the 32-bit denominator is an exact multiple of 13
or 119, which makes both 1300/7 MHz and 119 MHz exact with no rounding. OUT1 uses R = 2 in
the LCLS-II image because a 185.714 MHz output with R = 4 would need the MultiSynth to run
at 742.9 MHz, above the 720 MHz limit; with R = 2 it runs at 371.4 MHz. The LCLS-I image
keeps R = 4 so that the MultiSynth runs at 476 MHz, which puts the fractional-divider spurs
further below the carrier than the R = 2 alternative (238 MHz).

Output driver settings (all four outputs): `OUT_FORMAT` = 1 (LVDS), `OUT_VDD_SEL` = 1.8 V,
`OUT_SYNC_EN` = 1, `OUTALL_DISABLE_LOW` = 1 (outputs enabled), zero-delay mode off,
DCO/FINC/FDEC masked for all N dividers.

## File formats

### `.csv`

Direct ClockBuilder Pro register export: `Address,Data` with 16-bit page/offset
addresses and 8-bit data, 502 writes per file. This is the human-readable source of
truth. Generate the `.mem` from it rather than editing the `.mem` by hand.

### `.mem`

Boot ROM image consumed by `surf.Si5394I2c` through the `MEMORY_INIT_FILE_G` generic. It
is a 1024-entry memory of 24-bit hex words, one per line, decoded as:

```
[23:20] unused (always 0)
[19:16] Si5394 page
[15:8]  register offset within the page
[7:0]   data byte
```

The firmware walks the ROM from entry 0 after the power-on-reset wait, issuing one paged
I2C write per non-zero entry. Special words:

- `FFFFFF`: pause for the calibration timeout (625 ms, long enough for every Si5394 grade).
- `000000`: end of image. Unused entries at the tail must be zero.

Each `.mem` wraps the CSV body with the ClockBuilder Pro preamble and postamble that the
reference manual requires around a full register download:

| Position  | Entries                                    | Purpose                                         |
|-----------|--------------------------------------------|-------------------------------------------------|
| Preamble  | `0B24C0` `0B2500` `054001` `FFFFFF`        | Enter download mode, then wait for calibration  |
| Body      | 502 words from the CSV                     | Frequency plan, output drivers, masks           |
| Postamble | `051401` `001C01` `054000` `0B24C3` `0B2502` | `BW_UPDATE_PLL`, `SOFT_RST_ALL`, exit download mode |
| Padding   | `000000` to 1024 entries                   | Terminates the boot sequence                    |

## Selecting an image

Set the `SI5394_INIT_FILE_G` generic on `XilinxAlveoU55cCore` (or `XilinxVariumC1100Core`)
to the `.mem` file name. Both `.mem` files are added to the Vivado project by
`hardware/XilinxAlveoU55c/ruckus.tcl`, so no other build changes are needed. After the
boot sequence completes, the same `Si5394I2c` AXI-Lite port gives software full paged
read/write access to the device for diagnostics or runtime changes.

## Adding a new configuration

1. In ClockBuilder Pro, start from one of the existing plans: Si5394, 40 MHz external
   reference on XA/XB, free-run, OUT2/OUT3 = 100 MHz on an integer N divider, OUT0/OUT1 on
   a second N divider at the desired GT reference frequency, all outputs LVDS 1.8 V.
   Alternatively, for a plan that only changes OUT1, edit the 156 MHz CSV directly the way
   the LCLS images were made: fill N2 (`0x0318..0x0321`, little-endian 44-bit numerator and
   32-bit denominator), point OUT1 at N2 (`0x011A` = 0x1a), pick the OUT1 R divider
   (`0x0117` bit 2 or `0x0253`), and enable N2 (`0x0A03` = 0x07, `0x0A05` = 0x07,
   `0x0B4A` = 0x08). Keep fVCO / N2 at or below 720 MHz.
2. Export the register map as CSV (`Address,Data`), without the CBPro preamble/postamble.
3. Convert each CSV row to a 6-hex-digit word (`page[7:0]` `offset[7:0]` `data[7:0]`),
   prepend the four-word preamble, append the five-word postamble, and zero-pad to 1024
   lines.
4. Add the new `.mem` to `hardware/XilinxAlveoU55c/ruckus.tcl` and
   `hardware/XilinxVariumC1100/ruckus.tcl` with `add_files -norecurse`.

## References

- Skyworks, *Si5395/94/92 Data Sheet* (register map section 4.14 defers to the RM)
- Skyworks, *Si5395-94-92 Family Reference Manual* (register descriptions, download procedure)
- AMD, *UG1469 Alveo U55C Data Center Accelerator Card User Guide*, "Clocks"
- AMD, *U55C master XDC* (`U55C_xdc_1v00.xdc`, "Clock Trees" header comment)
- `surf/devices/Silabs/si5394/rtl/Si5394I2cCore.vhd` (boot ROM state machine)
