function[varargout] = version
%% dash.version  Return the current version of the DASH toolbox
% ----------    
%   dash.version
%   Prints the current version to the console
%
%   v = dash.version  
%   Returns the version as a string
% ----------
%   Outputs:
%       v (string scalar): The current version string of the DASH toolbox
%
% <a href="matlab:dash.doc('dash.version')">Documentation Page</a>

version = "v4.2.2";
if nargout==0
    disp(version);
else
    varargout = {version};
end

end
