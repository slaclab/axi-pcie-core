# Configuration file for the Sphinx documentation builder.
# https://www.sphinx-doc.org/en/master/usage/configuration.html

project = 'axi-pcie-core'
author = 'SLAC National Accelerator Laboratory'
copyright = '2026, SLAC National Accelerator Laboratory'
release = ''

extensions = ['sphinx.ext.extlinks']

extlinks = {
    'repo': ('https://github.com/slaclab/axi-pcie-core/blob/main/%s', '%s'),
}

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

source_suffix = '.rst'
master_doc = 'index'
language = 'en'

html_theme = 'furo'
html_static_path = ['_static']
