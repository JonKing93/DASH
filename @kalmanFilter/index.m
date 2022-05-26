function[varargout] = index(obj, name, type, varargin)
%% kalmanFilter.index  Specify climate indices to calculate from the posterior of a Kalman Filter
% ----------
%   obj = obj.index(...)
%   Calculates a climate index from a posterior climate field for each
%   member of a posterior ensemble. Returns the full posterior for the
%   calculated index, without needing to save the (often very large) full
%   posterior of the entire climate field.
% 
%   A common motivation for data assimilation is to reconstruct a climate
%   index of some sort, and having the full posterior of the climate
%   index is useful for quantifying reconstruction uncertainty. Often,
%   climate indices are calculated using values across a large spatial
%   field. In order to calculate the full posterior of such climate indices,
%   data values are needed for the full posterior of the associated spatial
%   field. However, this present a problem, because the full posteriors of
%   spatial fields are often too large for computer memory. This method
%   allows you to circumvent these memory issues by calculating a climate
%   index from the posterior fields, saving the full posterior for the
%   climate index, and then discarding the large posterior field.
%
%   obj = obj.index(name, type, ...)
%   Calculates an index when the Kalman filter is run. The first input is
%   an identifying name that the filter should use for the index. You can
%   specify multiple indices that should be calculated, so long as they use
%   different names. When using the kalmanFilter.run method, the output
%   struct will hold the posterior for the index in a field named: index_<name>
% 
%   The second input indicates the type of calculation that should be used
%   to compute the index. All subsequent inputs will depend on the type of
%   calculation being used. The syntaxes for different types of
%   calculations are detailed below.
%
%   names = obj.index
%   Returns the names of the indices that will be calculated from the 
%   posterior when the Kalman filter is run.
%
%   obj = obj.index(name, 'delete')
%   Deletes the index with the specified name from the Kalman Filter
%   object. These indices will no longer be calculated when the Kalman
%   filter is run.
%
%   obj = obj.index(name, 'mean', ...)
%   obj = obj.index(..., 'rows', rows)
%   obj = obj.index(..., 'weights', weights)
%   obj = obj.index(..., 'nanflag', nanOption)
%   Calculates the index using a mean over state vector elements. Use the
%   "rows" flag to only implement the mean over specific state vector rows.
%   If you do not provide the "rows" flag, takes a mean
%   over all the elements in the state vector. Use the "weights" flag to
%   implement a weighted mean over the selected state vector elements. If
%   you do not provide the "weights" flag, implements an unweighted mean.
%   Use the "nanflag" flag to indicate how to treat NaN values in the state
%   vector when taking a mean. If you do not specify the "nanflag" flag,
%   includes NaN elements in the mean.
% ----------
%   Inputs:
%       name (string scalar): An identifying name for the calculated index.
%           The name must be a valid Matlab variable name. It must start
%           with a letter, and can only contain letters, numbers, and
%           underscores.
%       type (string scalar): Indicates the type of calculation to use to 
%           compute the climate index.
%           ['mean']: Implements a mean over state vector elements in each
%               posterior ensemble member.
%       rows (logical vector [nState] | vector linear indices [nRows]): Indicates
%           which state vector rows to use in the weighted mean. If a
%           logical vector, must have one element per state vector row. If
%           not set, selects every row in the state vector.
%       weights (numeric vector [nRows]): The weights to use for a weighted
%           mean of the selected state vector elements. Must have one
%           element per state vector row used in the mean. If you provided
%           a "rows" input, the order of weights must match the order of
%           input rows. Otherwise, the order of weights should match the
%           order of elements in the state vector.
%       nanOption (string scalar | scalar logical): Indicates how to treat
%           NaN elements in a state vector when taking a mean.
%           ["omitnan"|false]: Omits NaN values when taking means
%           ["includenan"|true (default)]: Includes NaN values when taking means
%
%   Outputs:
%       obj (scalar kalmanFilter object): The object with updated posterior
%           index calculations.
%       names (string vector): The names of the indices that will be
%           calculated when the Kalman filter is run.
%
% <a href="matlab:dash.doc('kalmanFilter.index')">Documentation Page</a>

%%%%% Parameter: Calculator name header
nameHeader = "index_";
%%%%%

% Setup
header = "DASH:kalmanFilter:index";
dash.assert.scalarObj(obj, header);

% Get the names of current indices. Strip "index_" header
indices = obj.calculationType==2;
names = obj.calculationNames(indices);
names = eraseBetween(names, 1, strlength(nameHeader));

% Return names.
if ~exist('name','var')
    varargout = {names};
    return
end

% Error check the name and type. Add "index_" header to name and check if
% the name is already an index
type = dash.assert.strflag(name, 'type', header);
userName = dash.assert.strflag(name, 'name', header);
name = strcat(nameHeader, userName);
[isindex, k] = ismember(name, obj.calculationNames);

% Delete. Check inputs
if strcmpi(type, 'delete')
    if numel(varargin)>0
        dash.error.tooManyInputs;
    elseif ~isindex
        notAnIndexError(obj, userName, header);
    end

    % Remove from object
    obj.calculations(k,1) = [];
    obj.calculationNames(k,1) = [];
    obj.calculationTypes(k,1) = [];
    
% Set. Check the type
else
    dash.assert.strsInList(type, "mean", 'type', 'recognized index type', header);

    % Check the name is valid and non-duplicate
    if isindex
        duplicateIndexError(obj, userName, header);
    elseif ~isvarname(userName)
        invalidNameError(userName, header);
    end

    % Error check and update index based on type
    if strcmpi(type, 'mean')
        obj = processMean(obj, header, varargin);
    end

    % Update the name
    obj.calculationNames(end+1,1) = name;
end

% Return updated object
varargout = {obj};

end

%% Utility functions
function[obj] = processMean(obj, header, varargin)

% Require nState to be set
try
    if obj.nState==0
        id = sprintf('%s:noStateVector', header);
        ME = MException(id, ['Cannot implement a "mean" index until the number of ',...
            'state vector elements has been set. Consider using the "kalmanFilter.prior" ',...
            'command before specifying a mean index.']);
        throwAsCaller(ME);
    end
    
    % Parse the inputs
    flags = ["rows", "weights", "nanflag"];
    defaults = {1:obj.nState, [], 'includenan'};
    [rows, weights, nanflag] = dash.parse.nameValue(varargin, flags, defaults, 2, header);
    
    % Error check the rows
    logicalReq = 'have one element per state vector row';
    linearMax = 'the number of rows in the state vector';
    rows = dash.assert.indices(rows, obj.nState, 'rows', logicalReq, linearMax, header);
    nRows = numel(rows);
    
    % Default and error check the weights
    if isempty(weights)
        weights = ones(nRows, 1);
    else
        dash.assert.vectorTypeN(weights, 'numeric', nRows, 'weights', header);
        dash.assert.defined(weights, 2, 'weights', header);
        weights = weights(:);
    end
    
    % Parse nanflag and get string
    switches = {"omitnan","includenan"}; %#ok<CLARRSTR> 
    includenan = dash.parse.switches(nanflag, switches, 1, 'nanOption', header);
    if includenan
        nanoption = "includenan";
    else
        nanoption = "omitnan";
    end

% Minimize error stacks
catch ME
    throwAsCaller(ME);
end

% Create the new calculator and add to the object
calculator = dash.posteriorCalculation.weightedMean(rows, weights, nanoption);
obj.calculations{end+1,1} = calculator;
obj.calculationTypes(end+1,1) = 2;

end


%% Error messages
function[] = notAnIndexError(obj, userName, header)
id = sprintf('%s:notAnIndex', header);
ME = MException(id, 'Cannot delete because "%s" is not an index in %s.', userName, obj.name);
throwAsCaller(ME);
end
function[] = duplicateIndexError(obj, userName, header)
id = sprintf('%s:duplicateIndex', header);
ME = MException(id, '"%s" is already an index in %s.', userName, obj.name);
throwAsCaller(ME);
end
function[] = invalidNameError(userName, header)
id = sprintf('%s:invalidName', header);
ME = MException(id, ['"%s" is not a valid Matlab variable name. Valid names must ',...
    'begin with a letter, and can only include letters, numbers, and underscores'],...
    userName);
throwAsCaller(ME);
end