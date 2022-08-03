# DASH
A package for paleoclimate data assimilation workflow.
[Website](https://jonking93.github.io/DASH)

DASH is a Matlab package to help implement paleoclimate data assimilation. It includes modules to help
1. Catalogue and organize climate data, 
2. Design state vector ensembles,
3. Implement proxy system models, and
4. Run Kalman filter, particle filter, and optimal sensor algorithms.

The documentation is currently being finalized, but will be available at: [https://jonking93.github.io/DASH](https://jonking93.github.io/DASH)


## Getting Started

To get started with the DASH toolbox:

1. Download the most recent stable release: [Latest Release](https://github.com/JonKing93/DASH/releases/latest)
2. Open the downloaded DASH.mltbx file. This should install the DASH toolbox in your MATLAB environment.
3. That's it you're done! For additional help, enter
```
>> dash.doc
```
in the MATLAB console. This will open the DASH documentation set, which includes resources for starting with DASH.


## Feedback / Contributions

Find a bug, or have an idea for a cool new feature? We welcome feedback! 
For bug reports, suggestions, or anything else - send us an email at DASH.toolbox@gmail.com

Interested in contributing? Either send us an email, or submit a pull request to the DASH repository to get started.


## Branches
The following is an overview of the branches of DASH

#### Permanent
main: This branch holds the most up-to-date source code for the DASH toolbox. This branch is intended for developers rather than users. It may contain active development and may not be stable. If you are looking to use the DASH toolbox, we recommend downloading [the most recent stable release](https://github.com/JonKing93/DASH/releases/latest).

releases: This branch holds the Matlab Toolbox file that can be used to install a supported release of the DASH toolbox. The branch holds a packaged DASH.mltbx file, but it does not hold the raw source code.

gh-pages: This branch holds the source code used to implement the DASH documentation website.


#### Defunct
v4-build: This branch was used to develop version 4. It will be removed once version 4 is validated on the main branch.

Tutorials: This branch holds Tutorials used to introduce users to version 2. It will be removed upon the completion of the version 4 documentation set.
