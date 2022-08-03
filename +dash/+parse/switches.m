function[switches] = switches(input, typeStrings, nSwitches, name, listName, header)
%% dash.parse.switches  Parse inputs that are logical, numeric, or string switches
% ----------
%   switches = dash.parse.switches(input, typeStrings, nSwitches)
%   Parses the states for a set of switches. Switch states are associated
%   with collections of strings that indicate a particular state. As an
%   alternative to strings, logical or numeric switch states may be used.
%   Parses switch states for multiple switches. If the switch state is not
%   scalar, requires a value for each switch.
%
%   ... = dash.parse.switches(..., name, listName, header)
%   Customize thrown error messages and identifiers.
% ----------
%   Inputs:
%       input: The input being parsed
%       typeStrings (cell vector [nStates] {string vector}): Strings
%           corresponding to the possible states of the switch. A cell
%           vector with one element per state. Each cell holds a string
%           vector with strings that can be used to select the state.
%       nSwitches (scalar positive integer): The number of switch-states
%           that are required.
%       name (string scalar): The name of the input
%       listName (string scalar): A name for the list of allowed strings
%       header (string scalar): Header for thrown error IDs
%
%   Outputs:
%       switches (scalar | vector [nSwitches], logical | integers): The 
%           parsed switch states. States are logical when there are two
%           states, or integers (from 0 to nStates-1) when there are more
%           than two states. This output will either have a single element
%           (same state for all switches) or one element per switch.
%
% <a href="matlab:dash.doc('dash.parse.switches')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = 'input';
end
if ~exist('listName','var') || isempty(listName)
    listName = "allowed option";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:switches";
end

% Convert strings
if dash.is.string(input)
    input = string(input);
end

% Check size
try
    if isequal(nSwitches,1)
        dash.assert.scalarType(input, [], name, header);
    elseif ~isscalar(input)
        vectorName = sprintf('Since it is not scalar, %s', name);
        dash.assert.vectorTypeN(input, [], nSwitches, vectorName, header);
    end

    % Count typeStrings, note whether to use logical or numeric
    nTypes = numel(typeStrings);
    useLogical = true;
    if nTypes>2
        useLogical = false;
    end

    % Parse logicals
    if useLogical && islogical(input)
        switches = input;
    
    % Numeric
    elseif ~useLogical && isnumeric(input)
        istype = ismember(input, 0:nTypes-1);
        if ~all(istype)
            bad = find(~istype,1);
            name = dash.string.elementName(bad, name, numel(input));
            id = sprintf('%s:numericInputNotSwitch', header);
            error(id, '%s (%f) is not a(n) %s. Allowed values are: %s.', ...
                name, input(bad), listName, dash.string.list(0:nTypes-1));
        end
        switches = input;

    % Strings
    elseif dash.is.strlist(input)
        input = string(input);
    
        % Get number of options and allowed strings
        nStrings = NaN(nTypes, 1);
        allowedStrings = strings(0,1);
        for t = 1:nTypes
            nStrings(t) = numel(typeStrings{t});
            allowedStrings = [allowedStrings; typeStrings{t}(:)]; %#ok<AGROW> 
        end

        % Get switches
        switches = dash.assert.strsInList(input, allowedStrings, name, listName, header);
        previous = 0;
        for t = 1:nTypes
            istype = switches>previous & switches<=previous+nStrings(t);
            switches(istype) = t-1;
            previous = previous + nStrings(t);
        end

        % Logical strings
        if useLogical
            switches = logical(switches);
        end

    % Anything else
    else
        secondType = 'numeric';
        if useLogical
            secondType = 'logical';
        end
        id = sprintf('%s:inputInvalidSwitch', header);
        error(id, '%s must either be a string or %s data type', name, secondType);
    end

    % Return columns
    if isrow(switches)
        switches = switches';
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end