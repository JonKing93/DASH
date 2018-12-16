function[] = mapState( M, iSize )
%% Returns a state vector to a 2D grid and plots it.
%
% mapState( M, iSize )
% Maps a state vector.
% 
% ----- Inputs -----
% 
% M: A state vector. (nState x 1)
%
% iSize: The original size of the 2D grid. (2 x 1)

M = reshape(M, iSize);
imagesc( flipud(M') );
colorbar;

end

