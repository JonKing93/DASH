function[siz] = size(siz)
%% dash.string.size  Prints a size as a string of integers separated by xs
% ----------
%   siz = dash.string.size(siz)
%   Converts a vector of lengths to a string of sizes separated by xs.
% ----------
%   Inputs:
%       siz (vector, integers): A set of dimension lengths
%       
%   Outputs:
%       siz (char row vector): The size as a string.
%
% <a href="matlab:dash.doc('dash.string.size')">Documentation Page</a>
siz = sprintf('%.fx', siz);
siz(end) = [];
end