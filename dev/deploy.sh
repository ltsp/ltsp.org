#!/bin/sh
# Script to deploy the site

# Option 1: latest upstream
pip install mkdocs-material
# Option 2: a proposed branch
# pip install git+https://github.com/squidfunk/mkdocs-material.git@refactor/compatibility
# Option 3: an older version that is compatible with Firefox 52 and IE
# pip install 'mkdocs-material<5'
# site_packages=$(pip show mkdocs-material | awk '/Location:/ { print $2 }')
# cp dev/el.html "$site_packages"/material/partials/language*/
pip install mkdocs-minify-plugin
pip install mkdocs-material-extensions
pip install mkdocs-redirects
pip install mkdocs-section-index
pip install mkdocs-with-pdf
ENABLE_PDF_EXPORT=1 mkdocs gh-deploy --force
