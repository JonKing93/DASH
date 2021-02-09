function[ens] = buildMatfile(obj, writable)
%% Updates an ensemble object using a matfile object and returns the matfile.
%
% ens = obj.buildMatfile(writable)
%
% ----- Inputs -----
%
% writable: Scalar logical. Whether to return a writable file.s
%
% ----- Outputs -----
% 
% ens: The matfile object associated with the ensemble object's .ens file.

% Default write permission
if ~exist('writable','var') || isempty(writable)
    writable = false;
end

% Check the file exists
dash.checkFileExists(obj.file);

% Build the matfile object
try
    ens = matfile(obj.file, 'Writable', writable);
catch
    error(['Could not load ensemble data from "%s". It may not be a .ens file. ',...
        'If it is a .ens file, it may have become corrupted.'], obj.file);
end

% Ensure all fields are present
required = ["X","metadata","stateVector"];
varNames = who(ens);
if any(~ismember(required, varNames))
    bad = find(~ismember(required, varNames),1);
    error('File "%s" does not contain the "%s" field.', obj.file, required(bad));
end

end