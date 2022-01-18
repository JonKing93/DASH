function[obj] = add(obj, variableNames, grids)
%% stateVector.add  Adds variables to a stateVector
% ----------
%   obj = obj.add(variableNames, grid)
%   Adds variables to a state vector and specifies a single .grid file that
%   contains the data for all the variables.
%
%   obj = obj.add(variableNames, grids)
%   Specify different .grid files for the variables being added to the
%   state vector. Each .grid file should contain the data for the
%   corresponding new variable. You may repeat .grid files when several
%   state vector variables are derived from the same .grid file.
% ----------
%   Inputs:
%       variableNames (string vector [nVariables]): The names of the new
%           variables being added to the state vector. Variable names
%           **DO NOT** need to match the names of variables in data source
%           files. Use any name you find meaningful. Names cannot duplicate
%           the names of variables already in the state vector.
%
%           Variable names must be valid MATLAB variable names. They must
%           1. start with a letter, 2. only contain numbers, letters,
%           and underscores, and 3. cannot match a MATLAB keyword.
%       grid (string scalar | scalar gridfile object): A .grid file that
%           contains the data for all the newly added variables. Either a
%           gridfile object, or the filepath to a .grid file.
%       grids (vector [nVariables], string | gridfile | cell {string | gridfile}):
%           The collection of .grid files that contain the data for the new variables.
%           Must have one element per new variable. May either be a vector
%           of gridfile objects, .grid filepaths, or a cell vector with
%           elements of either type.
%
%   Outputs:
%       obj (scalar stateVector object): The stateVector object updated to
%           include the new variables.
%
% <a href="matlab:dash.doc('stateVector.add')">Documentation Page</a>

% Setup
header = "DASH:stateVector:add";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Error check the names of the new variables
vars = dash.assert.strlist(variableNames, 'variableNames', header);
vars = vars(:);
obj.assertValidNames(vars, header);
nVariables = numel(vars);

% If not scalar, grids must be a vector with one element per variable. If
% scalar, use the single grid for all variables
nGrids = numel(grids);
if nGrids > 1
    dash.assert.vectorTypeN(grids, [], nVariables, 'grids', header);
    gridIndices = (1:nVariables)';
else
    gridIndices = ones(nVariables, 1);
end

% If not a cell, require string list or gridfile vector.
if ~isa(grids, 'cell')
    if ~isa(grids, 'gridfile') && ~dash.is.strlist(grids)
        invalidGridsTypeError;
    end

    % Convert to cell column vector
    if nGrids>1 && isrow(grids)
        grids = grids';
    end
    grids = mat2cell(grids, ones(nGrids,1), 1); %#ok<MMTC> 
end

% Convert filepaths to gridfile objects
for g = 1:nGrids
    if dash.is.strflag(grids{g})
        grids{g} = gridfile(grids{g});
    end
end

% Add each new state vector variable
for v = 1:nVariables
    g = gridIndices(v);
    newVariable = dash.stateVectorVariable(grids{g});
    obj.variables_ = [obj.variables_; newVariable];
end

% Update variable properties
v = obj.nVariables + (1:nVariables);
obj.allowOverlap(v) = false;

obj.coupled(v,:) = true;
obj.coupled(:,v) = true;

obj.nVariables = v(end);
obj.variableNames = [obj.variableNames; vars];

end