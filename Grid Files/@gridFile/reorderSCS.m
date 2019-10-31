function[start, count, stride] = reorderSCS( start, count, stride, gridOrder, sourceOrder )

% Get the source order over all dimensions including trailing singletons
[insource] = ismember( gridOrder, sourceOrder );
sourceOrder = [sourceOrder, gridOrder(~insource)];

% Permute the data to the source file order
[~, reorder] = ismember( sourceOrder, gridOrder );
start = start( reorder );
count = count( reorder );
stride = stride( reorder );

end