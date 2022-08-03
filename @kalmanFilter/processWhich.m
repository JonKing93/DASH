function[obj] = processWhich(obj, whichArg, field, nIndex, indexType, timeIsSet, whichIsSet, header)
%% kalmanFilter.processWhich  Parses and processes which inputs for priors, R, and covariance options
% ----------
%   obj = obj.processWhich(whichArg, field, nIndex, indexType, timeIsSet, whichIsSet, header)
%   Interprets whichR and whichPrior inputs. Error checks to ensure that
%   which arguments are the correct length and valid indices. Sets nTime if
%   appropriate. Saves the which argument for evolving values. Records an
%   empty array for static values.
% ----------
%   Inputs:
%       whichArg: The whichR or whichPrior argument being parsed
%       field (string scalar): Indicates which field to update
%       nIndex (nR | nPrior): Indicates the number of R uncertainties or
%           number of priors that the which argument can index into
%       indexType (string scalar): Identifying name for the indices
%       timeIsSet (scalar logical): True is time is set for the filter and
%           should not be updated via whichArg. False if whichArg can
%           update nTime.
%       whichIsSet (scalar logical): True if whichArg is already set by
%           another data input and should not be updated. False if whichArg
%           can update the field.
%       header (string scalar): Header for thrown error IDs
% 
%   Outputs:
%       obj (scalar kalmanFilter object): The updated filter object
%
% <a href="matlab:dash.doc('kalmanFilter.processWhich')">Documentation Page</a>

% Unspecified which argument. If already set by another data field, use the
% existing value.
try
    if isempty(whichArg)
        if whichIsSet
            whichArg = obj.(field);
    
        % Otherwise if evolving, set time when unset. If set, require one index
        % per time step
        elseif nIndex > 1
            if ~timeIsSet
                obj.nTime = nIndex;
            end
            if nIndex ~= obj.nTime
                wrongSizeError(obj, indexType, header);
            end
            whichArg = (1:obj.nTime)';
        end
    
    % User-provided which argument. If already set by a different data field,
    % require identical values.
    elseif whichIsSet
        if isrow(whichArg)
            whichArg = whichArg';
        end
        if ~isequal(whichArg, obj.(field))
            differentWhichError(field, header);
        end
    
    % Otherwise, user values can set the which argument. If time is set,
    % require one index per time step. If unset and evolving, set nTime to the
    % number of indices
    else
        nRequired = [];
        if timeIsSet
            nRequired = obj.nTime;
        elseif nIndex > 1
            obj.nTime = numel(whichArg);
        end
        dash.assert.vectorTypeN(whichArg, 'numeric', nRequired, field, header);
        linearMax = sprintf('the number of %s', indexType);
        dash.assert.indices(whichArg, nIndex, field, [], linearMax, header);
    end
    
    % Only record the which argument if evolving
    if nIndex > 1
        obj.(field) = whichArg(:);
    else
        obj.(field) = [];
    end

% Minimize error stack
catch ME
    if startsWith(ME.identifier, "DASH")
        throwAsCaller(ME);
    else
        rethrow(ME);
    end
end

end

% Error messages
function[] = wrongSizeError(obj, type, header)
id = sprintf('%s:wrongNumberElements', header);
ME = MException(id, 'The number of %s must match the number of time steps (%.f).',...
    type, obj.nTime);
throwAsCaller(ME);
end
function[] = differentWhichError(field, header)
id = sprintf('%s:differentWhichArg', header);
ME = MException(id, ['The %s input was already set by a previous command, and the ',...
    'new values do not match the old values. Since you already provided a %s ',...
    'input, you do not need to provide one in this command. If you want to change ',...
    'the %s values, you may need to delete their associated data inputs from ',...
    'the filter.'], field, field, field);
throwAsCaller(ME);
end