function[nVariables] = nVariables(obj, scope)
%% ensemble.nVariables  Returns the number of variables for the elements of an ensemble array
% ----------
%   nVariables = obj.nVariables
%   Returns the number of used variables for each element of an ensemble
%   array.
%
%   ... = obj.nVariables(scope)
%   ... = obj.nVariables(false|"u"|"used")
%   ... = obj.nVariables( true|"f"|"file")
%   Indicate the scope in which to count variables. If false, behaves
%   identically to the previous syntax and returns the number of used
%   variables for each element of an ensemble array. If true, returns the
%   number of variables stored in the .ens file for each element of an
%   ensemble array.
% ----------

% Parse the scope
header = "DASH:ensemble:nVariables";
useFile = obj.parseScope(scope, header);

% Count variables
nVariables = NaN(size(obj));
for v = 1:numel(obj)
    if useFile
        nVariables(v) = numel(obj(v).variables_);
    else
        nVariables(v) = sum(obj(v).use);
    end
end

end