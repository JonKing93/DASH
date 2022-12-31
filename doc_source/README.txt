The doc_source subfolder holds the resources needed to build the documentation HTML pages for DASH.

Its contents include:

1. examples
A directory holding the examples for the documentation pages. Examples are written in markdown and organized in the same file hierarchy as DASH.

2. reST parsers
Packages and functions used to convert DASH help text and example markdown into restructured text (reST) files for use with Sphinx.
Note that you don't need to run these parsers directly. Instead, use the documentDASH function (item 4 below).

3. sphinx
Resources needed for sphinx (v4.2.0) to build the documentation pages. This includes

    A. resources
    Includes all assets required by sphinx that are not the reference reST files. This includes the conf.py configuration file, the tutorial, and any other non-reference rst files for the documentation.

    B. source
    The reST files built by the parsers.

    C. python-package-mods
    Modifications to python packages to customize the look and feel of the documentation pages. Includes:

        i. pygments (v2.10.0)
        matlab.py: A custom code highlighting scheme mimicking the MATLAB editor. Place it in <python path>/Python/Lib/site-packages/pygments/styles

        ii. sphinx-rtd-theme (v1.0.0)
        theme.css added collapsible accordion sections and improved formatting of example code blocks. Place in <python path>/Python/Lib/site-packages/sphinx-rtd-theme/static/css
        breadcrumbs.html hardcodes the DASH Github Page into the top-right Github link. Place in <python path>/Python/Lib/site-packages/sphinx-rtd-theme

4. documentDASH.m
Runs the documentation parsers, builds the sphinx .rst files, then runs sphinx to build html help pages.

5. build
Built documentation resources. Includes:

    A. html
    The built html pages. These pages are for inspecting the build to make sure it completed properly. Move its contents to DASH/doc/html to make the documentation accessible to the dash.doc command.