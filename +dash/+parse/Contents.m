%% dash.parse  Functions that parse user inputs
% ----------
% Variable inputs:
%   vararginFlags           - Parse flags from varargin
%   nameValue               - Parse flagged options from Name,Value pairs
%
% Two types:
%   inputOrCell             - Parse inputs that are either cell vector of arrays, or a single array
%   stringsOrIndices        - Parse inputs that are either a list of strings, or a vector of indices
%   stringsOrLogcals        - Parse inputs that may either be logicals or strings associated with logicals
%   nameValueOrCollection   - Parse inputs that are either Name,Value pairs, or collected Name,Value pairs
%
% Unit tests:
%   tests                   - Unit tests for the dash.parse package
%
% <a href="matlab:dash.doc('dash.parse')">Documentation Page</a>