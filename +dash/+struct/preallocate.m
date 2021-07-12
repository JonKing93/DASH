function[s, inputs] = preallocate( fields, siz )
%% Preallocates a struct array. Fills all fields with empty arrays.
%
% [s, inputs] = dash.preallocateStruct(fields, siz)
%
% ----- Inputs -----
%
% fields: A cell vector. Each element contains the name of a field in the
%    structures.
%
% siz: The size of the preallocated struct array
%
% ----- Outputs -----
%
% s: The struct array
%
% inputs: A cell vector that can be used to pass inputs to create a
%    struct. Elements 1:2:end-2 are field names.

nFields = numel(fields);
inputs = repmat( {[]}, [1, nFields*2] );
inputs(1:2:end) = fields;
s = repmat( struct(inputs{:}), siz );

end