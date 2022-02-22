function[] = source(obj, source, showAllDetails)
%% gridfile.source  Display gridfile data source in console
% ----------
%   <strong>obj.source</strong>(s)
%   <strong>obj.source</strong>(sourceName)
%   Prints information about a data source to the console.
%
%   <strong>obj.source</strong>(..., showAllDetails)
%   Specify whether the methods should print all details about the data
%   source to the console. By default, only prints basic details.
% ----------
%   Inputs:
%       s (logical vector [nSources] | scalar linear index): The index
%           of the data source to print to the console.
%       sourceName (string scalar): The name of the data source to print to
%           the console
%       showAllDetails (scalar logical | string scalar): Whether to display
%           all data source details in the console or only a basic set of 
%           details. Default is to display the basic set.
%           [true | "a" | "all"]: Display all details
%           [false | "b" | "basic"]: Display basic details
%
%   Outputs:
%       Prints information about the data source to the console.
%
% <a href="matlab:dash.doc('gridfile.source')">Documentation Page</a>

% Setup
header = "DASH:gridfile:source";
dash.assert.scalarObj(obj, header);
obj.update;

% Get the index of the data source. Exit if empty. Otherwise, only allow a
% single source
s = obj.sources_.indices(source, header);
s = unique(s);
if isempty(s)
    return
elseif numel(s)>1
    tooManySourcesError;
end

% Default, parse details
if ~exist('showAllDetails','var') || isempty(showAllDetails)
    showAllDetails = false;
else
    showAllDetails = dash.parse.switches(showAllDetails, {["b","basic"],["a","all"]},...
        2, 'showAllDetails', 'allowed option', header);
end

% Get info and metadata for the source
info = obj.info(s);
metadata = obj.metadata(s);

% Title the data source
fprintf('\n');
fprintf('  Data Source %.f in gridfile "%s":\n\n', s, obj.name);

% File, variable, dimensions
fprintf('          File: %s\n', info.file);
if isfield('variable',info)
    fprintf('      Variable: %s\n', info.variable);
end
fprintf('    Dimensions: %s\n', strjoin(info.dimensions,', '));
fprintf('\n');

% Dimension size and metadata
obj.dispDimensions(metadata);

% Data adjustments (fill, range, transform)
obj.dispAdjustments(info.fill_value, info.valid_range, info.transform, info.transform_parameters);

% Link to all details if not displaying everything
if ~showAllDetails
    link = sprintf('<a href="matlab:%s.source(%.f, true)">Show all details</a>', inputname(1), s);
    fprintf('  %s\n\n', link);
    return
end

% Relative path, file type, data type, import options
fields = ["File Type";"Data Type";"Relative Path";"Import Options"];
printField = [true;true;false;false];

if info.uses_relative_path
    printField(3) = true;
end
if ~isempty(info.import_options)
    printField(4) = true;
end

width = max(strlength(fields(printField)));
format = sprintf('    %%%.fs: ', width);

if printField(3)
    fprintf([format, '<gridfile>/%s\n'], fields(3), info.path);
end
fprintf([format,'%s\n'], fields(1), info.file_type);
fprintf([format,'%s\n'], fields(2), info.data_type);
if printField(4)
    fprintf([format,'\b'], fields(4));
    disp(info.import_options);
else
    fprintf('\n');
end

% Unmerged dimensions and sizes
if ~isequal(info.dimensions, info.raw_dimensions)
    fprintf('    Raw Dimensions: %s\n', strjoin(info.raw_dimensions, ', '));
    fprintf('          Raw Size: %s\n\n', dash.string.size(info.raw_size));
end

end