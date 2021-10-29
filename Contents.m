%% DASH  Contents of the DASH toolbox
%
%% INFRASTRUCTURE
% The following classes help facilitate data assimilation workflows. Although they
% are strongly recommended, they are not required to actually implement any
% assimilation algorithms.
%
% gridfile         - Catalogue and load gridded datasets
% stateVector      - Design, build, and save state vector ensembles
% ensemble         - Load subsets of saved state vector ensembles
% ensembleMetadata - Locate data elements within a state vector ensemble
% PSM              - Build and run proxy-system models
%
%
%% ASSIMILATION
% The following classes implement various data assimilation algorithms
%
% kalmanFilter     - Ensemble square-root Kalman Filters
% particleFilter   - Particle Filters
% optimalSensor    - Optimal Sensors
%
%
%% DOCUMENTATION
% Components of DASH's documentation. To get help with DASH, see also:
% >> help dash.doc
% 
% doc/html         - HTML Documentation Pages DASH's contents. (Best viewed in a web browser)
% doc_source       - The source code used to generate the doc pages.
%
%
%% OTHER
% Code utilities; odds and ends.
%
% dash             - Utility code for the DASH toolbox
% testdata         - Saved data used for unit-testing
% README.md        - A description of the toolbox
% Contents.m       - This file
% .gitattributes   - Ensure correct interactions between Matlab and git version control
% .gitignore       - Items not added to git version control