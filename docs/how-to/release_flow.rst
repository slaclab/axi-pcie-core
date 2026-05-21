Release Flow
============

**Goal:** Tag a versioned release on GitHub and let CI handle packaging and
publication. This page documents the ``axi-pcie-core`` release pipeline: what
a tag triggers, what artefacts are produced, and how consumers obtain them.

For the upstream reusable-workflow schema (``releases.yaml`` structure,
``releaseGen.py`` inputs, and the ``gen_release.yml`` calling conventions),
refer to the `slaclab/ruckus firmware release how-to
<https://github.com/slaclab/ruckus/blob/main/docs/how-to/firmware_release.rst>`_.

Prerequisites
-------------

- Write access to the ``slaclab/axi-pcie-core`` repository.
- A ``GH_TOKEN`` personal access token with ``repo`` scope configured as a
  GitHub Actions secret in the repository settings.
- All changes committed and pushed; the working tree on the target commit must
  be clean.

Step 1: Tag Convention
-----------------------

All releases use semantic versioning in the form ``vX.Y.Z``. Recent tags
illustrate the convention:

.. code-block:: text

   v6.7.0
   v6.6.1
   v6.6.0
   v6.5.1
   v6.5.0

- Patch releases (``Z`` increment) fix bugs without breaking the ``<Board>Core``
  port list.
- Minor releases (``Y`` increment) add new boards or extend feature generics.
- Major releases (``X`` increment) introduce breaking changes to board-core
  ports or the ``AxiPciePkg`` constants.

Step 2: Tag the Commit and Push
--------------------------------

.. code-block:: bash

   git tag vX.Y.Z
   git push origin vX.Y.Z

Pushing the tag triggers the tag-gated jobs in
:repo:`.github/workflows/axi_ci.yml`.

What Gets Published
--------------------

A ``vX.Y.Z`` tag push triggers two jobs:

1. **GitHub release** — the ``gen_release`` job calls
   ``slaclab/ruckus/.github/workflows/gen_release.yml@main`` via the GitHub
   Actions reusable-workflow mechanism. It runs ``ruckus/scripts/releaseGen.py``
   to create a GitHub release with auto-generated release notes.

2. **Debian package** — the ``build-deb-pkg`` job builds a self-contained
   ``fpga-pcie-reprogram-vX.Y.Z_amd64.deb`` using ``conda-pack`` and the
   ``upload-deb-pkg`` job attaches it to the GitHub release (along with a
   ``checksums.txt`` SHA-256 manifest). The package wraps
   :repo:`scripts/updatePcieFpga` and its rogue/pyrogue runtime into a single
   ``dpkg``-installable artefact.

.. note::

   A conda channel publish (formerly to the ``tidair-tag`` channel) is **no
   longer part of this flow**. See :ref:`migration-note` below.

How to Consume a Release
-------------------------

**Source consumers (git submodule):**

.. code-block:: bash

   git checkout vX.Y.Z

Pin a specific tag in your downstream project's ``.gitmodules`` or
``ruckus.tcl`` submodule initialisation to lock against a known-good release.

**Firmware-update tool (Debian package):**

Download ``fpga-pcie-reprogram-vX.Y.Z_amd64.deb`` from the GitHub release
assets page, then install:

.. code-block:: bash

   dpkg -i fpga-pcie-reprogram-vX.Y.Z_amd64.deb

The installed ``fpga-pcie-reprogram`` command wraps
:repo:`scripts/updatePcieFpga`.

Safety Checks
--------------

The ``gen_release``, ``build-deb-pkg``, and ``upload-deb-pkg`` jobs all
require ``startsWith(github.ref, 'refs/tags/')``. On non-tag pushes
(including pushes to ``main`` and feature branches) only the
``test_and_document`` job runs; no release artefacts are produced.

The ``test_and_document`` job (flake8 + ``python -m compileall``) is a
dependency of ``gen_release``, so a tag push that fails linting will not
produce a release.

.. _migration-note:

Migration Note
--------------

The ``conda-recipe/`` directory and the ``tidair-tag`` conda channel publish
were removed in this release. Downstream consumers who previously installed
via:

.. code-block:: bash

   conda install -c tidair-tag axi_pcie_core

must switch to one of the following alternatives:

- **Git submodule** — pin a specific ``vX.Y.Z`` tag in your project.
  Downstream consumers should switch to the submodule integration path
  documented in :doc:`/how-to/integrate_as_submodule`.
- **Debian package** — install ``fpga-pcie-reprogram-vX.Y.Z_amd64.deb`` from
  the GitHub release assets (covers the firmware-update script use case).

The ``pip install`` path via ``setup.py`` is unaffected and remains supported.

Upstream Schema Reference
--------------------------

This page intentionally does not redocument the ``ruckus`` reusable-workflow
input schema. The ``releaseGen.py`` script interface, ``releases.yaml``
format, and full ``gen_release.yml`` calling conventions are documented in
the `slaclab/ruckus firmware release how-to
<https://github.com/slaclab/ruckus/blob/main/docs/how-to/firmware_release.rst>`_.
