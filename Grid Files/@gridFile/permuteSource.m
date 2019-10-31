function[X] = permuteSource( X, sourceOrder, gridOrder )

% Get the source order over all dimensions including trailing singletons
[insource] = ismember( gridOrder, sourceOrder );
sourceOrder = [sourceOrder, gridOrder(~insource)];

% Permute the data to the grid file order
[~, permOrder] = ismember( gridOrder, sourceOrder );
X = permute( X, permOrder );

end
