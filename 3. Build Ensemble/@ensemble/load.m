function[M] = load( obj )
%% Loads an ensemble
%
% M = obj.load

% Get the file
m = matfile( obj.fileName );

% Check if members are equally spaced. Get the load indices, remove
% unnecessary indices.
[cols, c] = sort( obj.loadMembers );
[~, unsort] = sort(c);
nCols = numel(cols);

keepCols = 1:nCols;
if numel(unique(diff(cols))) ~= 1
    keepCols = ismember( cols(1):cols(end), cols );
    cols = cols(1):cols(end);
end

% Read data from file, only keep desired elements. Unsort to specified order
M = m.M( :, cols );
M = M( :, keepCols );
M = M( :, unsort );

end