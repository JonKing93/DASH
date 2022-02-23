function[] = variable(obj, variable, dimensions, detailed, suppressVariable)
%% stateVector.variable  Display state vector variable in console
% ----------
%   obj.variable(v)
%   obj.variable(variableName)
%   obj.variable(..., 0)
%   Prints concise information about a variable to the console. Links to
%   more detailed information about the variable. Also links to information
%   about each dimension.
%
%   obj.variable(variable, dimensions)
%   obj.variable(variable, -1)
%   Also displays information about the listed variables in the console.
%   If -1 is used as the dimensions input, displays information about all
%   dimensions.
%
%   obj.variable(variable, dimensions, detailed)
%   Specify whether to print detailed, or concise information about the
%   variable and dimensions in the console. By default, displays concise
%   information.
%
%   obj.variable(variable, dimensions, detailed, suppressVariable)
%   Specify whether to suppress information about the variable. If
%   dimensions are specified and the variable is suppressed, only prints
%   information about the dimensions to the console. If no dimensions are
%   specified, prints the variable as usual. By default, the variable's
%   information is not suppressed.
% ----------

% Setup
header = "DASH:stateVector:variable";
dash.assert.scalarObj(obj, header);

% Parse indices
v = obj.variableIndices(variable, true, header);
v = unique(v);
if isempty(v)
    return
elseif numel(v)>1
    tooManyVariablesError;
end

% Parse dimension indices
if ~exist('dimensions','var') || isempty(dimensions) || isequal(dimensions, 0)
    dims = [];
elseif isequal(dimensions, -1)
    dims = 1:numel(obj.variables_(v).dimensions);
else
    dims = obj.dimensionIndices(v, dimensions, header);
end
nDims = numel(dims);

% Parse detailed
if ~exist('detailed','var') || isempty(detailed)
    detailed = [false, false];
else
    detailed = dash.parse.switches(detailed, {["c","concise"],["d","detailed"]}, ...
        2, 'detailed', 'allowed option', header);
    if numel(detailed)==1
        detailed = [detailed detailed];
    end
end

% Parse variable suppression
if ~exist('suppressVariable','var') || isempty(suppressVariable)
    suppress = false;
else
    suppress = dash.parse.switches(suppressVariable, {["r","retain"],["s","suppress"]},...
        1, 'suppressVariable', 'allowed option', header);
end

% Exit if there is not a variable
if isempty(v)
    return
end

% Get the information necessary for display
if suppress
    info = obj.variables_(v).info;
else
    info = obj.info(v);
end
objName = inputname(1);

% Print the variable (when not suppressed)
if ~suppress
    fprintf('  <strong>Variable: %s</strong>\n', info.name);
    fprintf('    gridfile: %s\n', info.gridfile);
    fprintf('      Length: %.f\n', info.length);
    fprintf('\n');
    fprintf('    Dimensions:\n');
    fprintf('           State: %s\n', strjoin(info.state_dimensions,', '));
    fprintf('        Ensemble: %s\n', strjoin(info.ensemble_dimensions,', '));

    % Print concise or detailed description
    if ~detailed(1)
        conciseVariable(objName, v);
    else
        verboseVariable(info);
    end
end

% Print dimensions
for k = 1:nDims
    d = dims(k);
    dimInfo = info.dimensions(d);
    dispDimension(dimInfo, objName, v, detailed(2));
end

% Note if all dimensions are displayed
allDims = 1:numel(info.dimensions);
allDims = all(ismember(allDims, dims));

% Link to dimensions
if isempty(dims)
    link = sprintf('<a href="matlab:%s.variable(%.f, -1, false, true)">Show dimensions</a>',...
        objName, v);
    fprintf('  %s\n', link);
elseif ~allDims
    detail = 'false';
    if detailed(2)
        detail = 'true';
    end
    link = sprintf('<a href="matlab:%s.variable(%.f, -1, %s, true)">Show all dimensions</a>',...
        objName, v, detail);
    fprintf('  %s\n', link);
end

% Link to all details
if ~all(detailed) || ~allDims
    link = sprintf('<a href="matlab:%s.variable(%.f, -1, true, false)">Show all details</a>',...
        objName, v);
    fprintf('  %s\n\n', link);
end

end

% Utilities
function[str] = cap(str)
str(1) = upper(str(1));
end
function[] = conciseVariable(objName, v)
link = sprintf('<a href="matlab:%s.variable(%.f, 0, true)">More details</a>',...
    objName, v);
fprintf('\n    %s\n\n', link);
end
function[] = verboseVariable(info)

% Trailing newline
fprintf('\n');

% Coupled variables
if ~isempty(info.coupled_variables)
    fprintf('     Coupled To: %s\n', strjoin(info.coupled_variables, ', '));
end

% Autocouple
autocouple = 'off';
if info.auto_couple
    autocouple = 'on';
end
fprintf('    Auto-couple: %s\n\n', autocouple);

% Overlap
overlap = 'Prohibited';
if info.allow_overlap
    overlap = 'Allowed';
end
fprintf('    Overlap: %s\n\n', overlap);

end

function[] = dispDimension(info, objName, v, detailed)

% Indices and their description
if strcmp(info.type,'state')
    nIndices = numel(info.state_indices);
    type = 'state';
elseif strcmp(info.type, 'ensemble')
    nIndices = numel(info.reference_indices);
    type = 'reference';
end

% Dimension name, type, length, number of indices
fprintf('    <strong>Dimension: %s</strong>\n', info.name);
fprintf('           Type: %s\n', cap(info.type));
fprintf('         Length: %.f\n', info.length);
fprintf('        Indices: %.f  (%s indices)\n', nIndices, type);

% Concise vs verbose display
if detailed
    verboseDimension(info);
else
    conciseDimension(info, objName, v);
end

end
function[] = conciseDimension(info, objName, v)

    % Initialize fields and link
    fields = ["Mean","Sequence","Metadata"];
    printField = [false, false, false];
    link = sprintf(['<a href="matlab:%s.variable(%.f, ''%s'', true, true)">',...
        'More details</a>'], objName, v, info.name);

    % Get fields to print
    if ~strcmp(info.mean.type, 'none')
        printField(1) = true;
    end
    if ~isempty(info.sequence)
        printField(2) = true;
    end
    if ~strcmp(info.metadata.type, 'raw')
        printField(3) = true;
    end

    % Print link and exit if no fields
    if ~any(printField)
        fprintf('        %s\n\n',link);
        return
    end

    % Get width format
    width = max(strlength(fields(printField)));
    format = sprintf('        %%%.fs: %%s\\n', width);

    % Print fields
    if printField(1)
        fprintf(format, fields(1), cap(info.mean.type));
    end
    if printField(2)
        fprintf(format, fields(2), 'True');
    end
    if printField(3)
        fprintf(format, fields(3), cap(info.metadata.type));
    end

    % Add link and end with newline
    fprintf('        %s\n\n', link);
end
function[] = verboseDimension(info)

% Mean
fprintf('\n');
fprintf('        Mean: %s\n', cap(info.mean.type));
if strcmp(info.mean.type, 'none')
    fprintf('\n');
else
    fprintf('            NaN Flag: %s\n', info.mean.nanflag);
    if isfield(info.mean, 'indices')
        fprintf('             Indices:');
        disp(info.mean.indices');
    else
        fprintf('\n');
    end
end

% Sequence
if isempty(info.sequence)
    fprintf('        Sequence: False\n\n');
else
    fprintf('        Sequence: True\n');
    siz = size(info.sequence.metadata);
    type = class(info.sequence.metadata);
    fprintf('            Metadata: [%.fx%.f %s]\n', siz(1), siz(2), type);
    fprintf('             Indices:');
    disp(info.sequence.indices');
end

% Metadata
type = info.metadata.type;
fprintf('        Metadata: %s\n', cap(type));
if strcmp(type, 'raw')
    fprintf('\n');
elseif strcmp(type, 'alternate')
    siz = size(info.metadata.values);
    type = class(info.metadata.values);
    fprintf('            Values: [%.fx%.f %s]\n\n', siz(1), siz(2), type);
elseif strcmp(type, 'convert')
    fprintf('            Function: %s\n', func2str(info.metadata.function));
    if isfield(info.metadata, 'args')
        fprintf('                Args:');
        disp(info.metadata.args);
    else
        fprintf('\n');
    end
end

end
