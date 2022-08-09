function[nVariables] = nVariables(obj, scope)
%% ensemble.nVariables  Returns the number of variables for the elements of an ensemble array
% ----------
%   nVariables = <strong>obj.nVariables</strong>
%   Returns the number of used variables for each element of an ensemble
%   array.
%
%   nVariables = <strong>obj.nVariables</strong>(scope)
%   ... = <strong>obj.nVariables</strong>(false|"u"|"used")
%   ... = <strong>obj.nVariables</strong>( true|"f"|"file")
%   Indicate the scope in which to count variables. If "used"|"u"|false, 
%   behaves identically to the previous syntax and returns the number of used
%   variables for each element of an ensemble array. If "file"|"f"|true, returns the
%   number of variables stored in the .ens file for each element of an ensemble array.
% ----------
%   Inputs:
%       scope (scalar logical | string scalar): Indicates the scope in
%           which to count variables.
%           ["used"|"u"|false (default)]: Returns the number of variables used by the ensemble
%           ["file"|"f"|true]: Return the number of variables saved in the .ens file
%
%   Outputs:
%       nVariables (numeric array): The number of variables in each element
%           of an ensemble array. Has the same size as obj.
%
% <a href="matlab:dash.doc('ensemble.nVariables')">Documentation Page</a>

% Default and parse scope
header = "DASH:ensemble:nVariables";
if ~exist('scope','var') || isempty(scope)
    scope = "used";
end
useFile = obj.parseScope(scope, header);

% Count variables
nVariables = NaN(size(obj));
for k = 1:numel(obj)
    if useFile
        nVariables(k) = numel(obj(k).variables_);
    else
        nVariables(k) = sum(obj(k).use);
    end
end

end