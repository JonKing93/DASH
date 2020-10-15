function[grid] = gridfile(obj)
%% Returns the gridfile object for a state vector variable. Returns an
% informative error message if it fails.
%
% grid = obj.gridfile;
%
% ----- Outputs -----
%
% grid: The gridfile object for a state vector variable.

% Get the gridfile object
try
    grid = gridfile(obj.file);
    
% Supplement error messages
catch ME
    message = sprintf('Could not build the gridfile object for variable %s.', var.name);
    cause = MException('DASH:stateVector:invalidGridfile', message);
    ME = addCause(ME, cause);
    rethrow(ME); 
end

end