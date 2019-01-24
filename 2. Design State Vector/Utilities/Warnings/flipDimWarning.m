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

fprintf(['The variables: ', sprintf('%s, ', coupVars{:}), '\b\b are coupled to %s\n'], var);
fprintf('Continuing will also convert %s in each of these variables to a %s dimension.\n',...
         dim, fromTo{2});

queryContinue('dimension conversion');
end

