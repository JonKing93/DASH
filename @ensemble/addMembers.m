function[] = addMembers(obj, nMembers, varargin)
%% ensemble.addMembers  Add more ensemble members to the ensemble saved in a .ens file
% ----------
%   obj = obj.addMembers(nMembers)
%
%   obj = obj.addMembers('all')
%
%   obj = obj.addMembers(..., 'strict', strict)
%   obj = obj.addMembers(..., 'strict', true|false)
% ----------


% Setup
header = "DASH:ensemble:addMembers";
dash.assert.scalarObj(header);

% Error check members
if isnumeric(nMembers)
    dash.assert.scalarType(nMembers, [], 'nMembers', header);
    dash.assert.positiveIntegers(nMembers, 'nMembers', header);
elseif ~strcmp(nMembers, 'all')
    id = sprintf("%s:invalidMembers", header);
    error(id, 'nMembers must either be a scalar positive integer, or "all".');
end

% Parse the other variables
flags = ["strict","precision","file","overwrite"];
defaults = {true,   [],        [],       []};
[strict, precision, file, overwrite] = dash.parse.nameValue(varargin, flags, defaults, 1, header);

% Redirect user if attempting to use unallowed stateVector.build flags
if ~isempty(precision)
    precisionError;
elseif ~isempty(file)
    fileError;
elseif ~isempty(overwrite)
    overwriteError;
end

% Error check strict
dash.assert.scalarType(strict, 'logical', 'strict', header);

% Load and validate the matfile. Get the ensemble precision
m = obj.validateMatfile;
info = whos(m, 'X');
precision = info.class;

% Deserialize the state vector. Use to load additional members
sv = m.stateVector.deserialize;
X = sv.addMembers(nMembers, 'strict', strict, 'precision', precision);

% Add to the matfile
m.Properties.Writable = true;
m.X(:, obj.totalMembers+(1:size(X,2))) = X;







% Default and check strictness
if ~exist('strict','var') || isempty(strict)
    strict = true;
else
    dash.assert.scalarType(strict, 'logical', 'strict', header);
end


