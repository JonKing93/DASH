function[] = doc(name)
%% dash.doc  Open online reference page in a web browser.
%
%   dash.doc(name)  opens the online reference page for a method, package,
%   or class in the DASH toolbox.
%
%   The name of the method, package, or class should include all
%   package/subpackage headers. For example:
%   >> dash.doc( "dash.is.strflag" )
%   >> dash.doc( "kalmanFilter" )
%   >> dash.doc( "kalmanFilter.prior" )
%
%   <a href="matlab:dash.doc('dash.doc')">Online Documentation</a>

% Reference page header
header = "https://jonking93.github.io/DASH/docs/ref";

% Parse the package headings into the url
name = string(name);
folders = strsplit(name, ".");
url = strcat(header, sprintf('/%s', folders));

% Open in browser
web(url);

end