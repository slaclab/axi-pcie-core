
from distutils.core import setup
from git import Repo

repo = Repo()

# Get version before adding version file
ver = repo.git.describe('--tags')
ver = ver.replace('-', '+', 1) # https://github.com/pypa/setuptools/issues/3772

# append version constant to package init
with open('python/axipcie/__init__.py','a') as vf:
    vf.write(f'\n__version__="{ver}"\n')

setup (
   name='axi_pcie_core',
   version=ver,
   packages=['axipcie', ],
   package_dir={'':'python'},
   scripts=['scripts/updatePcieFpga']
)

