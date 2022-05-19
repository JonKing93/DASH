%% dash  Utilities for the DASH toolbox
% ----------
%   This package contains various utilities that help the DASH toolbox run.
%   Most of the contents here are "under-the-hood" functions, but there are
%   a few contents that may be useful to users. In particular, we think
%   users may be interested in:
%
%   dash.doc       The fuction that opens the documentation browser
%   dash.closest   Can help users locate points close to specific coordinates
%   dash.math      Various mathematical functions that users may find useful
%   dash.version   Reports the current version of the DASH toolbox.
% ----------
% Documentation Functions:
%   doc                 - Open online reference page in a web browser
%   version             - Return the current version of the DASH toolbox
%
% User utilities:
%   closest             - Functions that find points closest to specified coordinates
%   math                - Functions that implement mathematical formulas
%
% Input Utilities:
%   is                  - Functions that test whether an input is a particular type
%   assert              - Functions that throw errors when an input does not match required criteria
%   parse               - Functions that parse user inputs
%
% Data Specific Utilities:
%   indices             - Functions that manipulate array indices
%   string              - Functions that manipulate strings
%   file                - Functions that facilitate file manipulation
%
% Console Notifications
%   warning             - Functions that manipulate warnings
%   error               - Functions that throw errors
%
% Classes:
%   dataSource          - Classes that read data from source files
%   gridfileSources     - A class to manage gridfile data source catalogues
%   stateVectorVariable - Implements a variable in a state vector
%
% Tests:
%   tests               - Implement unit tests for functions, classes, and sub-packages in the dash utility package
%   testToolbox         - Implement unit tests for all components of the DASH toolbox
%       
% <a href="matlab:dash.doc('dash')">Documentation Page</a>