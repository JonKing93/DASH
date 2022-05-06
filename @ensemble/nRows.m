function[nRows] = nRows(obj, scope)
%% ensemble.nRows  Return the number of rows for the ensemble objects in an array
% ----------
%   nRows = obj.nRows
%   Returns the number of state vector rows being used for each element of
%   an ensemble array.
%
%   nRows = obj.nRows(scope)
%   ... = obj.nRows(false|"u"|"used")
%   ... = obj.nRows( true|"f"|"file")
%   Indicate the scope in which to count rows. If "used"|"u"|false, behaves
%   identically to the previous syntax and counts the rows of variables
%   being used by each ensemble. If "file"|"f"|true, counts the rows of
%   variables saved in the .ens file for each ensemble.
% ----------
%   Inputs:
%       scope (scalar logical | string scalar): Indicates the scope in
%           which to count rows.
%           ["used"|"u"|false (default)]: Counts rows of variables used by the ensemble
%           ["file"|"f"|true]: Counts rows of variables saved in the .ens file
%
%   Outputs:
%       nRows (numeric array): The number of rows for each element of an 
%           ensemble array. Has the same size as obj.
%
% <a href="matlab:dash.doc('ensemble.nRows')">Documentation Page</a>

% Default and parse scope
header = "DASH:ensemble:nRows";
if ~exist('scope','var') || isempty(scope)
    scope = "used";
end
scope = obj.parseScope(scope, header);

% Count rows
nRows = NaN(size(obj));
for k = 1:numel(obj)
    nRows(k) = obj.length(0, scope);
end

end