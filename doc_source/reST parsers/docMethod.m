function[] = docMethod(classTitle, name, examplesRoot)

% Ignore methods inherited from handle
supers = superclasses(classTitle);
if ismember('handle', supers)
    handleMethods = string(methods('handle'));
    if ismember(name, handleMethods)
        return;
    end
end

% Get method title and help text
title = strcat(classTitle, '.', name);
header = get.help(title);

% Ignore inherited methods
[~, isinherited] = parse.methodClass(header);
if isinherited
    return;
end

% Ignore undefined constructors
classHelp = get.aboveLink( get.help(classTitle) );
methodHelp = get.aboveLink( header );
if isequal(classHelp, methodHelp)
    return;
end

% Document as function
examples = strcat(examplesRoot, filesep, name);
docFunction(title, examples);

end