function[] = dispVariables(obj)
%% ensembleMetadata.dispVariables  Prints the variables in a state vector to the console
% ----------
%   obj.dispVariables
%   Prints the variables in the state vector to the console. Prints the
%   name of each variable, its length, and the details of its state
%   dimensions.
% ----------
%   Outputs:
%       Prints a list of variables, lengths, and state dimensions to the console.
%
% <a href="matlab:dash.doc('ensembleMetadata.dispVariables')">Documentation Page</a>

% Exit if there are no variables
if obj.nVariables==0
    fprintf('        No variables\n\n');
    return
end

% Get width format for variable names and number of rows
nRows = string(obj.lengths);
rowsWidth = max(strlength(nRows));
nameWidth = max(strlength(obj.variables_));
format = sprintf('        %%%.fs - %%%.fs rows', nameWidth, rowsWidth);

% Get dimension details
details = strings(obj.nVariables, 1);
for v = 1:obj.nVariables
    stateDims = obj.stateDimensions{v};
    if isempty(stateDims)
        details(v) = "";

    % Note state means and sequences
    else
        ismean = obj.stateType{v}==1;
        stateDims(ismean) = strcat(stateDims(ismean), " mean");
        issequence = obj.stateType{v}==2;
        stateDims(issequence) = strcat(stateDims(issequence), " sequence");

        % Combine with size information
        sizes = string(obj.stateSize{v});
        stateDims = strcat(stateDims, ' (', sizes, ')');
        details(v) = strjoin(stateDims, ' x ');
    end
end

% Include details in format
detailsWidth = max(strlength(details));
detailsFormat = sprintf('   |   %%-%.fs', detailsWidth);
format = [format, detailsFormat, '\n'];

% Print each variable
for v = 1:obj.nVariables
    fprintf(format, obj.variables_(v), nRows(v), details(v));
end
fprintf('\n');

end