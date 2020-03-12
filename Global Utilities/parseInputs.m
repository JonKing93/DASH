function[varargout] = parseInputs( inArgs, flags, defaults, switches )
%% Parses inputs for (string-flag, value) input pairs and for boolean string switches.
%
% [values] = parseInputs( inArgs, flags, defaults, switches )
%
% ----- Inputs -----
%
% inArgs: typically, varargin for a function call
%
% flags: All the possible string flags
%
% defaults: The default value for the value associated with each string flag
%
% switches: A cell of allowed strings for string switches, OR a 'b' character for 
%           boolean string switches, OR an empty array if neither of these
%           options is applicable.
%
% ----- Outputs -----
%
% values: The values for each string flag in order of flag input.
%
% ----- Written By -----
%
% Jonathan King, 2017, University of Arizona

% Convert string flags to cell vector
if isstring( flags )
    flags = cellstr(flags);
end

% Make sure everything is formatted correctly
errorCheck(flags, defaults, switches);

% Initialize output to default values
varargout = defaults;

% If inputs were specified...
if ~isempty( inArgs )
    
    % An array to record whether a value has been set already
    setValue = false(length(flags));
    
    % Record whether an arg is a flag or a value
    valueID = NaN;
    
    % For each input argument
    for k = 1:length(inArgs)
        
        % Get the current arg
        arg = inArgs{k};
        
        % If this is a value...
        if ~isnan(valueID)
            
            % If this is a string switch...
            if ~isempty(switches{valueID})
                % Check that this is a string...
                if ~ischar(arg) || ~isvector(arg)
                    error('The value following ''%s'' is not a string.',flags{valueID});
                % ...and that it is an allowed string.
                elseif ~any( strcmpi( arg, switches{valueID} ) );
                    error('The input following ''%s'' is not a recognized string.', flags{valueID});
                end
            end
            
            % ...record in the output array.
            varargout{valueID} = arg;
            
            % Note that this value has been set by the user
            setValue(valueID) = true;
            
            % Next input is not a value, return valueID to NaN
            valueID = NaN;
        
        % Otherwise, this is a string flag
        else
            
            
            % Get the identity of the string
            valueID = find( strcmpi(arg, flags) );
            
            % If the arg does not match a flag, it is unrecognized
            if isempty(valueID)
                error('Unrecognized input...');
            end
                     
            % Check that this flag has not already been set
            if setValue( valueID )
                error('The ''%s'' value is being set multiple times.',arg);
            end
            
            % If this is a boolean switch...
            if isequal(switches{valueID}, 'b')
                % Set value to the opposite of default
                varargout{valueID} = ~varargout{valueID};
                setValue(valueID) = true;
                valueID = NaN;
            end
        end
    end
    
    % Ensure that there is no "hanging" flag
    if ~isnan(valueID)
        error('There is no value following ''%s''.',flags{valueID});
    end
end
end
        
        
function[] = errorCheck(flags, defaults, switches)
% Ensure that everything is formatted properly.

% Ensure that flags, defaults and switches are all cell vectors
if ~iscell(flags) || ~isvector(flags)
    error('flags must be a cell vector.');
elseif ~iscell(defaults) || ~isvector(defaults)
    error('defaults must be a cell vector.');
elseif ~iscell(switches) || ~isvector(switches)
    error('switches must be a cell vector.');
end

% Ensure that the number of flags, defaults, and switch values match
if length(flags)~=length(defaults) || length(flags)~=length(switches)
    error('The number of flags, defaults, and switches do not match.');
end

% Ensure that all flags are strings
for k = 1:length(flags)
    if ~ischar(flags{k}) || ~isvector(flags{k})
        error('All flags must be strings.');
    end
    
    % And that no flags are duplicates
    if sum( ismember(flags{k}, flags ) ) > 1
        error('Duplicate flags are not allowed.');
    end
end

% Ensure that all switches are [], 'b', or a cell vector of strings
for k = 1:length(switches)
    if isempty(switches{k})
        % Do nothing
    elseif isequal(switches{k}, 'b')
        % Ensure that the default is a boolean
        if ~islogical( defaults{k} )
            error('''%s'' is a boolean switch, but its default value is not a boolean.',flags{k});
        end
    elseif iscell(switches{k}) && isvector(switches{k})
        for j = 1:length(switches{k})
            if ~ischar(switches{k}{j}) || ~isvector(switches{k}{j})
                error('switches(%0.f) contains non-string values',k)
            end
        end
    else
        error('Unrecognized value in switches. All switches must be {}, ''b'' or a cell vecctor of strings.');
    end
end

end