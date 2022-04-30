function[obj] = constructor(files)
%% ensemble.ensemble  Returns an ensemble object for a .ens file.
% ----------
%   obj = ensemble(file)
%   Builds a ensemble object for the specified file.
%
%   obj = ensemble(files)
%   Builds an array of ensemble objects for the specified files. The output
%   array will have the same size as the "files" input and each element
%   will be the ensemble object for the associated file.
% ----------
%   Inputs:
%       file (string scalar | character row vector): The name of a .ens
%           file. If the file name does not end in a .ens extension, adds
%           the extension to the file name.
%       files (string array | cellstring array): A set of .ens files. The
%           output array of ensemble objects will have the same size as
%           this input.
%
%   Outputs:
%       obj (scalar ensemble object | ensemble array): An ensemble object
%           for the file or ensemble array for the set of files.
%
% <a href="matlab:dash.doc('ensemble.ensemble')">Documentation Page</a>

% Header for error IDs
header = "DASH:ensemble";

% Require strings array with at least one element
files = dash.assert.string(files);
if isempty(files)
    id = sprintf('%s:emptyFilenames', header);
    error(id, 'filenames cannot be empty');
end

% If scalar, build the object
if isscalar(files)
    file = dash.assert.fileExists(files, '.ens', header);
    obj.file = dash.file.urlSeparators(file);

    m = matfile(''

