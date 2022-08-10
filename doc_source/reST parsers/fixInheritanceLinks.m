function[] = fixInheritanceLinks
%% fixInheritanceLinks  Correct the reference links to inherited methods in class summary RST
% ----------
%   fixInheritanceLinks
%   Currently, the reST parsers do not account for inherited methods when
%   documenting class methods. Consequently, the reference links to
%   inherited methods point to the wrong locations. This method fixes the
%   links to known inherited methods by updating the reference link to the
%   superclass in the class RST
% ----------

% Get the list of inherited methods and their replacements. This list
% excludes inherited methods in PSM subclasses, which are processed below
% class, method, location
inherited = [...
    "kalmanFilter", "dispFilter", "dash/ensembleFilter"
    "kalmanFilter", "assertValidR", "dash/ensembleFilter"
    "kalmanFilter", "finalize", "dash/ensembleFilter"
    "kalmanFilter", "loadPrior", "dash/ensembleFilter"
    "kalmanFilter", "Rcovariance", "dash/ensembleFilter"

    "particleFilter", "dispFilter", "dash/ensembleFilter"
    "particleFilter", "assertValidR", "dash/ensembleFilter"
    "particleFilter", "finalize", "dash/ensembleFilter"
    "particleFilter", "loadPrior", "dash/ensembleFilter"
    "particleFilter", "Rcovariance", "dash/ensembleFilter"
    "particleFilter", "processWhich", "dash/ensembleFilter"

    "dash/dataSource/nc", "load", "hdf"
    "dash/dataSource/nc", "setVariable", "hdf"
    "dash/dataSource/mat", "load", "hdf"
    "dash/dataSource/mat", "setVariable", "hdf"

    "PSM/prysm", "rows", "Interface"
    "PSM/prysm", "estimate", "Interface"
    ];

% Iterate through each item
for k = 1:size(inherited)
    class = inherited(k,1);
    method = inherited(k,2);
    location = inherited(k,3);
    fixLink(class, method, location);
end

% Also fix the PSM subclasses
methods = ["label", "name", "parseRows", "disp"];
subclasses = ["bayfox","baymag","bayspar","bayspline","linear","prysm","vslite"];
for c = 1:numel(subclasses)
    class = strcat("PSM/", subclasses(c));
    for m = 1:numel(methods)
        fixLink(class, methods(m), "Interface");
    end
end

end

% Utilities
function[] = fixLink(class, method, location)

% Get the file and read the RST
file = strcat(class, '.rst');
rst = fileread(file);

% Get the class short name
classParts = split(class, '/');
classTitle = string(classParts(end));

% Replace inheritance links
pattern = sprintf("| :doc:`%s <%s/%s>`", method, classTitle, method);
replacement = sprintf("| :doc:`%s <%s/%s>`", method, location, method);
rst = replace(rst, pattern, replacement);

% Write the file
fid = fopen(file, 'w');
closeFile = onCleanup( @()fclose(fid) );
rst = replace(rst, '\n', newline);
fprintf(fid, '%s', rst);

end
