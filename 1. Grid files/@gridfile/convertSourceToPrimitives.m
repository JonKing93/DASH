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
s.file = char(source.file);
s.var = char(source.var);
s.dataType = char(source.dataType);

% Numeric variables stay the same
s.unmergedSize = source.unmergedSize;
s.merge = source.merge;
s.mergedSize = source.mergedSize;

% Dimension order becomes a comma delimited char array
s.unmergedDims = gridfile.commaDelimitedDims( source.unmergedDims );
s.mergedDims = gridfile.commaDelimitedDims( source.mergedDims );

% Record whether this is an .nc or .mat data source
if isa(source, 'ncSource')
    s.type = 'nc';
elseif isa(source, 'matSource')
    s.type = 'mat';
end

end