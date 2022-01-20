function[switches] = switches(input, typeStrings, nSwitches, name, listName, header)
%% dash.parse.switches  Throw error if input is neither a set of logical/numeric switches, nor a set of strings associated with switches
% ----------
%   switches = dash.assert.switches(input, typeStrings, nSwitches)
%   

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

% Check size
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

end