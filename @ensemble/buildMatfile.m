function[ens] = buildMatfile(obj)
%% Builds and checks a matfile object for a .ens file
%
% ens = obj.buildMatfile
%
% ----- Outputs -----
%
% ens: The matfile for the .ens file.

% Check the file exists
dash.checkFileExists(obj.file);

% Build the matfile object
try
    ens = matfile(obj.file);
catch
    error(['Could not load ensemble data from "%s". It may not be a .ens file. ',...
        'If it is a .ens file, it may have become corrupted.'], obj.file);
end

% Ensure all fields are present
required = ["X","hasnan","meta","stateVector"];
varNames = who(ens);
if any(~ismember(required, varNames))
    bad = find(~ismember(required, varNames),1);
    error('File "%s" does not contain the "%s" field.', obj.file, required(bad));
end

end