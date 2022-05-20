function[variableNames, v] = identify(obj, rows)
%% ensembleMetadata.identify  Identifies the variables associated with rows of a state vector
% ----------
%   [variableNames, v] = obj.identify
%   Returns the name of the variable associated with each row of a state
%   vector. Also returns the index of each variable as the second output.
%   The outputs will have one element per row in the state vector.
%
%   ... = obj.identify(rows)
%   ... = obj.identify(-1)
%   Returns the names and indices of the variables associated with the
%   specified rows. If the input is -1, selects all rows. The outputs will
%   have one element per listed row.
% ----------
%   Inputs:
%       rows (-1 | logical vector | vector, linear indices): Rows of the
%           state vector for which to identify the associated variables. If
%           -1, selects all state vector rows. If a logical vector, must
%           have the same length as the state vector.
%
%   Outputs:
%       variableNames (string vector [nRows]): The names of the variables
%           associated with each of the listed rows.
%       v (vector, linear indices [nRows]): The indices of the variables
%           associated with each of the listed rows.
%
% <a href="matlab:dash.doc('ensembleMetadata.identify')">Documentation Page</a>

% Setup
header = "DASH:ensembleMetadata:identify";
dash.assert.scalarObj(obj, header);

% Parse the rows
nRows = sum(obj.lengths);
if ~exist('rows','var') || isequal(rows, -1)
    rows = 1:nRows;
else
    logicalReq = 'have one element per state vector row';
    linearMax = 'the number of rows in the state vector';
    rows = dash.assert.indices(rows, nRows, 'rows', logicalReq, linearMax, header);
end

% Preallocate variable indices and get variable limits
nRows = numel(rows);
v = NaN(nRows, 1);
limits = dash.indices.limits(obj.lengths);

% Although we could use broadcasting to identify the variables, this can
% get expensive when using many rows. Since the number of variables will
% typically be smaller than the number of state vector elements, iterate
% through variables to identify rows.
for k = 1:obj.nVariables
    isvariable = rows>=limits(k,1) & rows<=limits(k,2);
    v(isvariable) = k;
end
variableNames = obj.variables_(v);

end