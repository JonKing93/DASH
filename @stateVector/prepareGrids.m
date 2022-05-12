function[grids, failed, cause] = prepareGrids(obj, header)
%% stateVector.prepareGrids  Build and validate gridfile objects for variables in a state vector
% ----------
%   [grids, failed, cause] = obj.prepareGrids(

% Default
if ~exist('header','var')
    header = "DASH:stateVector:prepareGrids";
end

% Object assertions
dash.assert.scalarObj(obj, header);
obj.assertUnserialized;

% Build gridfiles from the saved file paths
[grids, failed, cause] = stateVector.buildGrids(obj.gridfiles);

% Check gridfiles match recorded values
if ~failed
    vars = 1:obj.nVariables;
    [failed, cause] = obj.validateGrids(grids, vars, header);
    if failed
        grids = [];
    end
end

end