function[tf] = url(name)
%% dash.is.url  Test if a name is a URL
% ----------
%   tf = dash.is.url(name)
%   Returns true if name is a URL. Otherwise, returns false.
% ----------
%   Inputs:
%       name (string scalar): The name being tested
%       
%   Outputs:
%       tf (scalar logical): True if the name is a URL. Otherwise false.
%
% <a href="matlab:dash.doc('dash.is.url')">Documentation Page</a>

name = char(name);
if (numel(name)>=7 && strcmp(name(1:7), 'http://')) || ...
   (numel(name)>=8 && strcmp(name(1:8), 'https://'))
    
    tf = true;
else
    tf = false;
end

end
    