# DASH
A package for paleoclimate data assimilation workflow.

DASH is a Matlab package to help implement paleoclimate data assimilation. It includes modules to help
1. Catalogue and organize climate data,
2. Design state vector ensembles,
3. Implement proxy system models, and
4. Run Kalman filter, particle filter, and optimal sensor algorithms.

----

This README includes instructions for:

* [Installing DASH](#install-dash),
* [Getting started with the toolbox](#getting-started)
* [Providing feedback and contributions](#feedback-contributions), and
* [A summary of repository branches](#branches)


## Install DASH

There are 3 different ways to install DASH:

1. [Using Github](#github),
2. [Via MATLAB's Add-On explorer](#matlab-add-on-explorer), or
3. [Using MATLAB File Exchange](#matlab-file-exchange)

### Github

1. Navigate to the most recent stable release: [Latest Release](https://github.com/JonKing93/DASH/releases/latest)
2. Under the release assets, download the file: `DASH-<version>.mltbx`
3. Open the downloaded file. This should automatically install the DASH toolbox in your MATLAB environment.
(If you previously installed a DASH toolbox using a .mltbx file, this will update your toolbox to the latest version)

### MATLAB Add-On Explorer

1. Click on the `Home` tab in the MATLAB editor,
2. Click on the `Add-Ons` or `Get Add-Ons` button,
3. Search for `DASH` and click on the entry for the toolbox (Its tagline is "A Matlab toolbox for paleoclimate data assimilation")
4. Click on the `Add` button in the top-right corner and follow the instructions.

### MATLAB File Exchange

1. Navigate to the submission for the toolbox: [DASH on FileExchange](https://www.mathworks.com/matlabcentral/fileexchange/120453-dash)
2. Click the `Download` button in the top right corner and select the `Toolbox` option. This should download a file with the name `DASH-<version>.mltbx`.
3. Open the downloaded file (its name should follow the pattern `DASH-<version>.mltbx`). This should automatically install the DASH toolbox in you MATLAB environment.


## Getting Started

To get started with the DASH toolbox, enter:
```
>> dash.doc
```
in the MATLAB console. This will open the DASH documentation set, which includes resources for starting with DASH. In particular, we recommend checking out the DASH tutorial. The tutorial begins with an overview of the DASH toolbox, and then provides step-by-step instructions and examples for using the components of DASH. We recommend budgeting several hours to complete the tutorial.

If you have not yet installed the toolbox, you can find the DASH documentation online here: [DASH Documentation](#https://jonking93.github.io/DASH/welcome.html)

And the tutorial is available here: [DASH Tutorial](https://jonking93.github.io/DASH/Tutorial/welcome.html)


## Feedback / Contributions

Find a bug, or have an idea for a cool new feature? We welcome feedback!
For bug reports, suggestions, or anything else - send us an email at DASH.toolbox@gmail.com

Interested in contributing? Either send us an email, or submit a pull request to the DASH repository to get started.


## Branches
The following is an overview of the branches of the DASH repository.

#### [main](https://github.com/JonKing93/DASH/tree/main)
This branch holds the most up-to-date source code for the DASH toolbox. This branch is intended for developers rather than users. It may contain active development and may not be stable. If you are looking to use the DASH toolbox, we recommend downloading and opening the `DASH-<version>.mltbx` file from [the most recent stable release](https://github.com/JonKing93/DASH/releases/latest).

#### [gh-pages](https://github.com/JonKing93/DASH/tree/v4_build)
This branch holds the source code used to implement the online DASH documentation website.
