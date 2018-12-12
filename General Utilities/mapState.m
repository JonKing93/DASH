function[] = mapState( M, iSize )
%% Returns a state vector to a 2D grid and plots
%
% M: A state vector
%
% iSize: The original size of the 2D grid.

M = reshape(M, iSize);
imagesc( flipud(M') );
colorbar;

end

