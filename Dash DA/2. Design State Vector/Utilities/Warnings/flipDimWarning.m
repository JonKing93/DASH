function[] = flipDimWarning( dim, var, fromTo, coupVars )
%% Warn user if a coupled variable changes dimension type.

fprintf('Dimension %s of variable %s is being converted from a %s to a %s dimension. \n', ...
    dim, var, fromTo{1}, fromTo{2} );

fprintf(['The variables: ', sprintf('%s, ', coupVars{:}), '\b\b\n'] );
fprintf('are coupled to %s. Continuing will also convert %s in each of these variables to a %s dimension.\n',...
         var, dim, fromTo{2});

queryContinue('dimension conversion');
end

