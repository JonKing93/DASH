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

1. Navigate to the most recent stable release: [Latest Release](https://github.com/JonKing93/DASH/releases/latest)
2. Under the release assets, download the file: `DASH-<version>.mltbx`
3. Open the downloaded file. This should automatically install the DASH toolbox in your MATLAB environment. 
(If you previously installed a DASH toolbox using a .mltbx file, this will update your toolbox to the latest version)
4. That's it, you're done! For additional help, enter:
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

### Permanent

#### [**main**](https://github.com/JonKing93/DASH/tree/main)
This branch holds the most up-to-date source code for the DASH toolbox. This branch is intended for developers rather than users. It may contain active development and may not be stable. If you are looking to use the DASH toolbox, we recommend downloading and opening the `DASH-<version>.mltbx` file from [the most recent stable release](https://github.com/JonKing93/DASH/releases/latest).

#### [**gh-pages**](https://github.com/JonKing93/DASH/tree/v4_build)
This branch holds the source code used to implement the DASH documentation website.


### Defunct

#### [v4_build](https://github.com/JonKing93/DASH/tree/v4_build)
This branch was used to develop version 4. It will be removed once version 4 is validated on the main branch.

#### [Tutorials](https://github.com/JonKing93/DASH/tree/Tutorials)
This branch holds Tutorials used to introduce users to version 2. It will be removed upon the completion of the version 4 documentation set.
