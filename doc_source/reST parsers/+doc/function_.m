function[] = function_(title, examples)
%% doc.function_  Builds the RST documentation file for a function.
% ----------
%   doc.function_(title, examples)
%   Combines an examples markdown file and function help text to create an
%   RST file for a function.
% ----------
%   Inputs:
%       title (string scalar): The full, dot-indexing name of the function
%       examples (string scalar): The absolute file path to the examples
%           file for the function.
%
%   Outputs:
%       Writes the RST file for a function

exampleFile = strcat(examples, ".md");
write.functionRST(title, exampleFile);

end
