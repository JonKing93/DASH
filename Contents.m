%% DASH  Contents of the DASH toolbox
%
%% INFRASTRUCTURE
% The following classes help facilitate data assimilation workflows. Although they
% are strongly recommended, they are not required to implement any
% assimilation algorithms.
%
% gridMetadata      - Describe gridded data sets
% gridfile          - Catalogue and load gridded datasets
% stateVector       - Design, build, and save state vector ensembles
% ensemble          - Load subsets of saved state vector ensembles
% ensembleMetadata  - Locate data elements within a state vector ensemble
% PSM               - Build and run proxy-system models
%
%
%% ASSIMILATION
% The following classes implement various data assimilation algorithms
%
% kalmanFilter      - Ensemble square-root Kalman Filters
% particleFilter    - Particle Filters
% optimalSensor     - Optimal Sensors
%
%
%% DOCUMENTATION
% The following items hold components of DASH's documentation
%
% doc/html          - HTML Documentation Pages of DASH's contents
% doc_source        - The source code used to generate the doc pages.
%
%
% ***Important***
% If you are trying to access the DASH documentation, enter:
% >> dash.doc
% in the console.
%
% To open the documentation for a particular component, use:
% >> dash.doc('component name')
%
% For example:
% >> dash.doc('gridfile.new')
% loads the HTML page for the "gridfile.new" command.
%
% You can also display documentation directy in the console using the "help"
% command. For example:
% >> help gridfile.new
% ***---------***
%
%
%% OTHER
% Code utilities; odds and ends.
%
% dash             - Utility codes for the toolbox
% testdata         - Data used for unit-testing
% README.md        - A description of the toolbox
% Contents.m       - This file
% .gitattributes   - Ensure correct interactions between Matlab and git version control
% .gitignore       - Items not added to git version control