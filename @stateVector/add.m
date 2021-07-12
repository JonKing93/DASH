function[obj] = add(obj, varNames, files, autoCouple, overlap)
%% Adds a variable to a stateVector.
%
% obj = obj.add(varName, file)
% Adds a variable to the state vector and specifies the .grid file that
% holds the data for the variable.
%
% obj = obj.add(varNames, file)
% Adds multiple variables to the state vector whose data are all stored in
% the same .grid file.
%
% obj = obj.add(varNames, files)
% Adds multiple variables to the state vector and specifies the associated
% .grid files.
%
% obj = obj.add(varName, file, autoCouple)
% Specify whether the variable should be automatically coupled to other
% variables in the state vector. Default is true.
%
% obj = obj.add(varName, file, autoCouple, overlap)
% Specify whether ensemble members for the variable can use overlapping
% information. Default is false.
%
% ----- Inputs -----
% 
% varName: A name to identify the variable in the state vector. A string
%    scalar or character row vector. Use whatever name you find meaningful,
%    does not need to match the name of anything in the .grid file. Cannot
%    repeat the name of a variable already in the stateVector object.
%
% file: The name of the .grid file that holds data for the variable. A
%    string scalar or character row vector.
%
% autoCouple: A scalar logical indicating whether to automatically couple
%    the variable to other variables in the state vector (true -- default)
%    or not (false).
%
% overlap: A scalar logical indicating whether ensemble members for the
%    variable can use overlapping data.
%
% ----- Outputs -----
%
% obj: The updated stateVector object.

% Default for autoCouple and overlap
if ~exist('autoCouple','var') || isempty(autoCouple)
    autoCouple = true;
end
if ~exist('overlap','var') || isempty(overlap)
    overlap = false;
end

% Ensure the vector is still editable
obj.assertEditable;

% Error check the variable names. Get the number of new variables
varNames = dash.assert.strlist(varNames, 'varNames');
obj.checkVariableNames(varNames, [], 'varNames', 'add new variables to');
nNew = numel(varNames);

% Error check the other inputs.
files = dash.assert.strlist(files, 'files');
dash.assert.vectorTypeN(autoCouple, 'logical', [], 'autoCouple');
dash.assert.vectorTypeN(overlap, 'logical', [], 'overlap');

% Check sizes and propagate scalar inputs
fields = {files, autoCouple, overlap};
fieldNames = {'files','autoCouple','overlap'};
for f = 1:numel(fields)
    nEls = numel(fields{f});
    if ~isscalar(fields{f}) && nEls~=nNew
        error('%s may either have 1 element or %.f elements (1 per new variable).', fieldNames{f}, nNew);
    end
    fields{f} = repmat(fields{f}(:), [nNew-nEls+1, 1]);
end
[files, autoCouple, overlap] = fields{:};

% Create each new variable (also error checks the .grid files)
for v = 1:nNew
    newVar = stateVectorVariable(varNames(v), files(v));
    obj.variables = [obj.variables; newVar];
    obj.coupled(end+1, end+1) = true;
end

% Update auto coupling and overlap
obj.overlap(end+(1:nNew), 1) = overlap;
obj.auto_Couple(end+(1:nNew), 1) = autoCouple;
if any(autoCouple)
    obj = obj.couple( obj.variableNames(obj.auto_Couple) );
end

end