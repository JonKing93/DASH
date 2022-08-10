function[examples] = examples(file)
%% get.examples  Return the text of the examples file
% ----------
%   examples = get.examples(file)
%   Returns the text of the examples file and removes any carriage returns.
% ----------
%   Inputs:
%       file (string scalar): The name of the examples file
%
%   Outputs:
%       examples (char vector): The text of the examples file

% Read file and remove carriage returns
if ~exist('file','var') || isempty(file) || ~isfile(file)
    examples = '';
else
    examples = fileread(file);
    examples(examples==13) = [];
end

end