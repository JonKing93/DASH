%% dash  Utilities for the DASH toolbox
% ----------
%   This package contains various utilities that help the DASH toolbox run.
%   Most of the contents here are "under-the-hood" functions, but there are
%   a few contents that may be useful to users. In particular, we think
%   users may be interested in:
%
%   dash.doc        - The function that opens the documentation browser
%
%   dash.closest    - Can help users locate points close to specific coordinates
%
%   dash.localize   - Functions that calculate covariance localization weights
%
%   dash.version    - Reports the current version of the DASH toolbox.
%
%   Alternatively, see the "Documentation" and "Miscellaneous" sections
%   below for user functions.
% ----------
% Documentation:
%   doc                     - Open DASH documentation pages
%   version                 - Return the current version of the DASH toolbox
%
% Miscellaneous:
%   closest                 - Functions that find points closest to specified coordinates
%   localize                - Functions that calculation covariance localization weights
%
% Input Utilities:
%   is                      - Functions that test whether an input is a particular type
%   assert                  - Functions that throw errors when an input does not match required criteria
%   parse                   - Functions that parse user inputs
%
% Data Specific Utilities:
%   indices                 - Functions that manipulate array indices
%   string                  - Functions that manipulate strings
%   file                    - Functions that facilitate file manipulation
%
% Math:
%   math                    - Functions that implement mathematical equations
%   kalman                  - Functions that implement the Kalman Filter equation
%
% Console Notifications:
%   warning                 - Functions that manipulate warnings
%   error                   - Functions that throw errors
%
% Classes:
%   dataSource              - Classes that read data from source files
%   gridfileSources         - A class to manage gridfile data source catalogues
%   stateVectorVariable     - Implements a variable in a state vector
%   ensembleFilter          - A class that implement common operations for Kalman and particle filters
%   posteriorCalculation    - Classes that perform calculations on Kalman Filter posterior deviations
%
% Tests:
%   tests                   - Implement unit tests for functions, classes, and sub-packages in the dash utility package
%   testToolbox             - Implement unit tests for all components of the DASH toolbox
%       
% <a href="matlab:dash.doc('dash')">Documentation Page</a>