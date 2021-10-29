The doc_source subfolder holds the resources needed to build the documentation HTML pages for DASH.

Its contents include:

1. examples
A directory holding the examples for the documentation pages. Examples are written in markdown and organized in the same file hierarchy as DASH.

2. reST parsers
Packages and functions used to convert DASH help text and example markdown into restructured text (reST) files for use with Sphinx.

3. sphinx
Resources needed for sphinx (v4.2.0) to build the documentation pages. This includes

    A. config
    The conf.py configuration file and the top-level index.rst

    B. source
    The reST files built by the parsers.

    C. python-package-mods
    Modifications to python packages to customize the look and feel of the documentation pages. Includes:

        i. pygments (v2.10.0)
        matlab.py: A custom code highlighting scheme mimicking the MATLAB editor. Place it in <python path>/Python/Lib/site-packages/pygments/styles

        ii. sphinx-rtd-theme (v1.0.0)
        theme.css added collapsible accordion sections and improved formatting of example code blocks. Place in <python path>/Python/Lib/site-packages/sphinx-rtd-theme/static/css
        breadcrumbs.html hardcodes the DASH Github Page into the top-right Github link. Place in <python path>/Python/Lib/site-packages/sphinx-rtd-theme

4. build
Built documentation resources. Includes

    A. html
    The built html pages. These pages are for inspecting the build to make sure it completed properly. Move its contents to DASH/doc/html to make the documentation accessible.