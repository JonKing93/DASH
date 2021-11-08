function[tf] = url(name)
%% dash.is.url  Tests if a name is a URL
% ----------
%   tf = dash.is.url(name)

name = char(name);
if (numel(name)>=7 && strcmp(name(1:7), 'http://')) || ...
   (numel(name)>=8 && strcmp(name(1:8), 'https://'))
    
    tf = true;
else
    tf = false;
end

end
    