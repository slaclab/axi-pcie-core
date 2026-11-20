#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
# Shared pytest/cocotb/GHDL launch path, modeled on surf's
# tests/common/regression_utils.py
#-----------------------------------------------------------------------------

from __future__ import annotations

from functools import lru_cache
import hashlib
import os
from pathlib import Path
import shlex
import subprocess

from cocotb_test.simulator import run

# Keep all repo-relative path resolution in one place
REPO_ROOT      = Path(__file__).resolve().parents[2]
TESTS_ROOT     = REPO_ROOT / "tests"
BUILD_SRC_ROOT = REPO_ROOT / "build" / "SRC_VHDL"

BASE_GHDL_COMPILE_ARGS = [
    "--std=08",
    "-fsynopsys",
    "-frelaxed-rules",
    "-fexplicit",
]

OPTIONAL_GHDL_WARNINGS = ("elaboration", "hide", "specs", "shared")


@lru_cache(maxsize=1)
def _supported_ghdl_warning_names() -> frozenset[str]:
    try:
        result = subprocess.run(
            [*shlex.split(os.environ.get("GHDL_CMD", "ghdl")), "--help-warnings"],
            check=True,
            capture_output=True,
            text=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return frozenset()

    names = set()
    for line in result.stdout.splitlines():
        tokens = line.strip().split(maxsplit=1)
        if not tokens or not tokens[0].startswith("-W") or tokens[0] == "-Wall":
            continue
        names.add(tokens[0].removeprefix("-W").removesuffix("*"))
    return frozenset(names)


def _vhdl_compile_args() -> list[str]:
    # Only pass the -Wno-<name> flags that the installed GHDL version knows
    supported_names = _supported_ghdl_warning_names()
    return [
        *BASE_GHDL_COMPILE_ARGS,
        *[f"-Wno-{name}" for name in OPTIONAL_GHDL_WARNINGS if name in supported_names],
    ]


def build_vhdl_sources() -> dict[str, list[str]]:
    """Return the ruckus-imported VHDL sources, keyed by VHDL library name."""
    if not BUILD_SRC_ROOT.is_dir():
        raise FileNotFoundError(
            "Missing imported HDL sources. Run `make MODULES=<dir with ruckus and surf> import` first."
        )

    return {
        lib_dir.name: [str(path) for path in sorted(lib_dir.iterdir()) if path.is_file()]
        for lib_dir in sorted(BUILD_SRC_ROOT.iterdir())
        if lib_dir.is_dir()
    }


def _sim_build_path(test_file: Path, parameters: dict[str, object] | None) -> str:
    rel_parent = test_file.resolve().relative_to(TESTS_ROOT).parent
    build_dir  = TESTS_ROOT / "sim_build" / rel_parent / test_file.stem
    if not parameters:
        return str(build_dir)

    # Parameter-specific build directories keep parallel pytest runs from
    # trampling each other's compile/elaboration artifacts.
    suffix = ",".join(f"{key}={value}" for key, value in sorted(parameters.items()))
    if len(suffix) > 120 or "/" in suffix or "\\" in suffix:
        suffix = f"params-{hashlib.sha256(suffix.encode()).hexdigest()}"
    return str(build_dir.with_name(f"{test_file.stem}.{suffix}"))


def run_vhdl_test(
    *,
    test_file: str | Path,
    toplevel: str,
    parameters: dict[str, object] | None = None,
    extra_env: dict[str, object] | None = None,
    sim_args: list[str] | None = None,
) -> None:
    """Launch one GHDL simulation of `toplevel` running the cocotb tests in `test_file`.

    `parameters` are VHDL generics. `extra_env` is Python-side case metadata
    passed to the cocotb module through the environment. `sim_args` are extra
    GHDL run-time options.
    """
    test_file = Path(test_file)
    simulator_env = {key: str(value) for key, value in (extra_env or {}).items()}
    sim_build_parameters = {
        **{key: str(value) for key, value in (parameters or {}).items()},
        **simulator_env,
    }

    run(
        toplevel=toplevel,
        # cocotb expects a Python import path for the module that contains the
        # @cocotb.test() entrypoints, not a filesystem path.
        module=".".join(test_file.resolve().relative_to(REPO_ROOT).with_suffix("").parts),
        toplevel_lang="vhdl",
        vhdl_sources=build_vhdl_sources(),
        parameters=parameters,
        sim_build=_sim_build_path(test_file, sim_build_parameters),
        extra_env=simulator_env,
        simulator="ghdl",
        vhdl_compile_args=_vhdl_compile_args(),
        sim_args=sim_args,
    )
