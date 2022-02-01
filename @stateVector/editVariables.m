function[obj] = editVariables(obj, vars, d, method, inputs, task)
%% stateVector.editVariables  Edit the design parameters of state vector variables
% ----------
%   obj = obj.editVariables(vars, d, method, inputs, task)
%   Applies the specified method to the given variables using indicated
%   inputs. Throws informative error message if the method fails.
% ----------
%   Inputs:
%       vars (vector, linear indices [nVars]): The indices of the variables
%           being edited
%       d (matrix, dimension indices [nVars x nDims]): The indices of
%           the dimensions being edited for each variable.
%       method (string scalar): The name of the method to apply to the variables
%       inputs (cell vector): Inputs to the method after the dimension indices
%       task (string scalar): The name of attempted task to use in thrown
%           error messages
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated variables
%
% <a href="matlab:dash.doc('stateVector.editVariables')">Documentation Page</a>

% Update each variable
for k = 1:numel(vars)
    v = vars(k);
    try
        dims = d(k,:);
        obj.variables_(v) = obj.variables_(v).(method)(dims, inputs{:});

    % Rethrow errors outside of DASH error handling
    catch cause
        if ~contains(cause.identifier, 'DASH')
            rethrow(cause);
        end

        % Otherwise, supplement error message
        id = cause.identifier;
        ME = MException(id, 'Cannot %s the "%s" variable of %s',...
            task, obj.variableNames(v), obj.name);
        ME = addCause(ME, cause);
        throwAsCaller(ME);
    end
end

end