function[] = flipDimWarning( dim, var, fromTo, coupVars )
%% Warn user if a coupled variable changes dimension type.
%
% dim: Dimension name
%
% var: Variable name
%
% fromTo: {'state','ensemble'} OR {'ensemble','state'}
%
% coupVars: Names of coupled variables
%
% ----- Written By -----
% Jonathan King, University of Arizona, 2019

fprintf('Dimension %s of variable %s is being converted from a %s to a %s dimension. \n', ...
    dim, var, fromTo{1}, fromTo{2} );

fprintf( ['\tConverting %s from %s to %s dimension for coupled variables: ', sprintf('%s, ', coupVars{:}), '\b\b\n'], dim, fromTo{1}, fromTo{2} );

end