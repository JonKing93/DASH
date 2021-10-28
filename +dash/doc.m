function[] = doc(name)
%% dash.doc  Open online reference page in a web browser.
% ----------
%   dash.doc(name)  
%   Opens the online reference page for a method, package, or class in the
%   DASH toolbox.
%
%   The name of the method, package, or class should include all
%   package/subpackage headers. For example:
%
%   >> dash.doc( "dash.is.strflag" )
%
%   >> dash.doc( "kalmanFilter" )
%
%   >> dash.doc( "kalmanFilter.prior" )
% ----------
%   Inputs:
%       name (string scalar): The full name of a method, package, or class
%           in the DASH toolbox.
%
%   <a href="matlab:dash.doc('dash.doc')">Documentation Page</a>

% Reference page header
path = mfilename('fullpath');
folders = strsplit(path, filesep);
docs = [folders(1:end-2), 'doc', 'html'];
header = strjoin(docs, filesep);

% Parse the package headings into the url
folders = strsplit(name, '.');
docPath = strjoin(folders, filesep);
docPath = [docPath, '.html'];
url = strjoin({header, docPath}, filesep);

% Open in browser
web(url);%, '-browser');

end