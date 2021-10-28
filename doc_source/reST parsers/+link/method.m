function[linked] = method(classTitle, methodName)

% Parse the defining class and whether the method is inherited
fullName = strcat(classTitle, '.', methodName);
header = get.help(fullName);
[superClass, isinherited] = parse.methodClass(header);

% If not inherited, link to class subfolder
if ~isinherited
    subfolder = parse.name(classTitle, true);
    
% If inherited, link to superclass subfolder
else
    
    % Currently all DASH subclasses are on the same level as their
    % superclasses. The following code is only valid for that assumption,
    % so make sure that this is actually the case before linking
    superParts = split(superClass, '.');
    classParts = split(classTitle, '.');
    assert(length(superParts) == length(classParts));
    assert(all(strcmp(superParts(1:end-1), classParts(1:end-1))));
    
    % Link to superclass subfolder
    subfolder = parse.name(superClass, true);
end

% Create the link
linked = link.content(subfolder, methodName);

end