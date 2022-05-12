function[] = dispVariables(obj, showFile)
%% ensemble.dispVariables  Prints the variables in an ensemble object to the console
% ----------
%   obj.dispVariable
%   Prints the variables being used by the ensemble object to the console.
%   Prints the state vector length of each variable in addition to its
%   name.
%
%   obj = obj.dispVariables(showFile)
%   Indicate whether to print the variables used by the ensemble object
%   (false - default), or the variables saved in the .ens file.
% ----------
%   Inputs:
%       showFile (scalar logical): Whether to display the variables saved
%           in the .ens file (true), or the variables used by the ensemble
%           object (false - Default).
%
%   Outputs:
%       Prints a list of variables and their lengths to the console.
%
% <a href="matlab:dash.doc('ensemble.dispVariables')">Documentation Page</a>

% Default
if ~exist('showFile','var')
    showFile = false;
end

% Get variable names and lengths
variables = obj.variables(-1, showFile);
lengths = string(obj.length(-1, showFile));

% Format the list
varLength = string(max(strlength(variables)));
lengthLength = string(max(strlength(lengths)));
format = strcat('        %',varLength,'s - %',lengthLength,'s rows\n');

% Note if this is the saved vector
tag = '';
if showFile
    tag = 'Saved ';
end

% Print to console
fprintf('    %sVector:\n', tag);
for v = 1:obj.nVariables(showFile)
    fprintf(format, variables(v), lengths(v));
end
fprintf('\n');

end