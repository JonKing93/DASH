function[] = docClass(title, examplesRoot)

% Use chars
title = char(title);
examplesRoot = char(examplesRoot);

% Write contents page
write.classRST(title);

% Move to content subfolder
subfolder = parse.name(title, true);
if ~isfolder(subfolder)
    mkdir(subfolder);
end
home = pwd;
goback = onCleanup( @()cd(home) );  % Return to initial location when function ends
cd(subfolder);

% Get methods in the class.
methodNames = string(methods(title));

% Attempt to document each method. Display problem method if failed
for m = 1:numel(methodNames)
    try
        docMethod(title, methodNames(m), examplesRoot);
    catch ME
        cause = MException('', '%s.%s', title, methodNames(m));
        ME = addCause(ME, cause);
        rethrow(ME);
    end
end

end