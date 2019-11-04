function[scs, keep] = loadKeep( index )

if ~issorted( index, 'strictascend')
    error('Indices must be strictly ascending.');
end
scs = NaN(3,1);

% Check for even spacing. If not, load the entire interval
loadInterval = index;
spacing = unique( diff(index) );
if numel(index)>1 && numel(spacing)>1
    loadInterval = index(1):index(end);
    scs(3) = 1;
elseif numel(index) > 1
    scs(3) = spacing;
else
    scs(3) = 1;
end

% Get the start and the count
scs(1) = loadInterval(1);
scs(2) = numel( loadInterval );
[~, keep] = ismember( index, loadInterval );

end