function[obj] = displayConsoleOutput(obj, verbose)
%% Specify whether the stateVector should print notifications to the console
%
% obj = obj.displayConsoleOutout( verbose )
%
% ----- Input -----
%
% verbose: A scalar logical. If true (default), the stateVector prints
%    messages to the console. If false, it does not.
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Error check. Set toggle
dash.assertScalarLogical(verbose, 'verbose');
obj.verbose = verbose;

end