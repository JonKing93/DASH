function[s] = convertSourceToPrimitives( source )
%% Converts a dataSource object to a structure of primitive data types.
% This allows .grid files with many data sources to save faster than
% directly saving cell or structure arrays.
%
% s = gridfile.convertSourceToPrimitives( source )
%
% ----- Inputs -----
%
% source: A dataSource object
%
% ----- Outputs -----
%
% s: A structure array that stores dataSource properties as primitive data
%    types.

% Initialize structure
s = struct();

% Convert strings to chars
s.source = char(source.source);
s.var = char(source.var);
s.dataType = char(source.dataType);

% Numeric variables stay the same
s.unmergedSize = source.unmergedSize;
s.merge = source.merge;
s.mergedSize = source.mergedSize;

% Dimension order becomes a comma delimited char array
s.unmergedDims = dash.string.commaDelimited( source.unmergedDims );
s.mergedDims = dash.string.commaDelimited( source.mergedDims );

% Record the type of data source
types = ["nc","mat","opendap"];
for t = 1:numel(types)
    if isa(source, strcat("dash.dataSource.", types(t)))
        s.type = types(t);
        break;
    end
end
if ~isfield(s, 'type')
    error('Unrecognized dataSource type');
end

% Post-processing fields
s.fill = source.fill;
s.range = source.range;
s.convert = source.convert;

end