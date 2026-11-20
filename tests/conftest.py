#-----------------------------------------------------------------------------
# This file is part of the 'axi-pcie-core'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'axi-pcie-core', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

from __future__ import annotations

import os

import find_libpython
from cocotb_tools import config


def _export_gpi_users() -> None:
    """Export GPI_USERS on behalf of cocotb-test (same approach as surf's tests/conftest.py).

    cocotb 2.1 moved responsibility for building GPI_USERS onto the test
    runner: the VPI shim refuses to start the embedded interpreter without it
    ("No GPI_USERS specified, exiting..."). cocotb-test does not set it, so
    the repo has to. It goes into os.environ because cocotb-test copies the
    whole os.environ into the simulator environment.
    """
    # An explicit GPI_USERS wins, matching cocotb's own runner precedence
    if "GPI_USERS" in os.environ:
        return

    libpython = os.environ.get("LIBPYTHON_LOC") or find_libpython.find_libpython()
    if libpython is None:
        raise RuntimeError(
            "find_libpython could not locate libpython, which cocotb needs to "
            "start the embedded interpreter. Install the Python development "
            "package, or set LIBPYTHON_LOC to the absolute libpython path."
        )

    # GPI_USERS is semicolon-delimited, and libpython has to precede the entry
    # point so the interpreter symbols are resolved before PyGPI loads.
    os.environ["GPI_USERS"] = f"{libpython};{config.pygpi_entry_point()}"


_export_gpi_users()
