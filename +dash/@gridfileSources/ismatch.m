function[tf, property, objValue, catalogueValue] = ismatch(obj, dataSource, s)
%% dash.gridfileSources.ismatch  Test if a dataSource object matches an entry in the catalogue
% ----------
%   tf = <strong>obj.ismatch</strong>(dataSource, s)
%   Returns true if a dataSource object matches the specified source in the
%   catalogue. Otherwise, returns false.
%
%   [tf, property, objValue, catalogueValue] = <strong>obj.ismatch</strong>(dataSource, s)
%   If the dataSource is not a match, returns information about the
%   properties that do not match the values in the catalogue. If a match,
%   the additional outputs are empty.
% ----------
%   Inputs:
%       dataSource (scalar dataSource object): A dataSource object to
%           compare with the catalogue.
%       s (numeric scalar): The index of a source in the catalogue to
%           compare with the dataSource object.
%
%   Outputs:
%       tf (logical scalar): True if the dataSource matches the catalogue
%           entry. Otherwise, false.
%       property (string scalar): If not a match, the name of the property
%           that did not match the catalogue. Otherwise, an empty char.
%       objValue: If not a match, the value of the property in the
%           dataSource object. Otherwise, an empty array.
%       catalogueValue: If not a match, the value of the property in the
%           catalogue. Otherwise, an empty array.
%
% <a href="matlab:dash.doc('dash.gridfileSources.ismatch')">Documentation Page</a>

% Initialize
tf = false;

% Compare type
property = 'type';
objValue = dataSource.dataType;
catalogueValue = obj.dataType(s);
if ~strcmp(objValue, catalogueValue)
    return;
end

% Compare sizes. Remove trailing singleton dimensions
property = 'size';
catalogueValue = strsplit(obj.size(s), ',');
catalogueValue = str2double(catalogueValue);
catalogueValue = formatSize(catalogueValue);
objValue = formatSize(dataSource.size);
if ~isequal(objValue, catalogueValue)
    return;
end

% Passed the tests
tf = true;
property = '';
objValue = [];
catalogueValue = [];

end
function[siz] = formatSize(siz)
lastDim = find(siz>1, 1, 'last');
siz = siz(1:lastDim);
if isempty(siz)
    siz = [1 1];
elseif isscalar(siz)
    siz = [siz, 1];
end
siz = sprintf('%.fx', siz);
siz(end) = [];
end