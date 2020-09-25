function[returnState] = parseDirection(type, nDims)
%% Parses type/returnState direction options and returns them as a logical.
%
% returnState = ensembleMetadata.parseDirection(type, nDims);
%
% ----- Inputs -----
%
% type: A direction input option for metadata.
%
% nDims: The number of listed dimensions.
%
% ----- Outputs -----
%
% returnState: Logical direction options.

returnState = dash.parseLogicalString(type, nDims, 'returnState', 'type', ...
    ensembleMetadata.directionFlags, ensembleMetadata.nStateFlags, ...
    'Metadata direction options');

end