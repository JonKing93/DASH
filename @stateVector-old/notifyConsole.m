function[obj] = notifyConsole(obj, verbose)
%% Specify whether the stateVector should print notifications to the console
%
% obj = obj.notifyConsole( verbose )
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
dash.assert.scalarType(verbose, 'verbose', 'logical', 'logical');
obj.verbose = verbose;

end