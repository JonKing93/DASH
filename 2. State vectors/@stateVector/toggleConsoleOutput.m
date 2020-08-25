function[obj] = toggleConsoleOutput(obj, verbose, warn)
%% Toggles whether a stateVector prints various messages and warnings to
% the console.
%
% obj = obj.toggleConsoleOutput(verbose)
% Specify whether messages are printed to the console.
%
% obj = obj.toggleConsoleOutput(verbose, warn)
% Specify whether warnings are displayed.
%
% ----- Inputs -----
%
% verbose: A scalar logical indicating whether to print messages to the
%    console (true) or not (false).
%
% warn: A scalar logical indicating whether to display warnings (true) or
%    not (false)
%
% ----- Outputs -----
%
% obj: The updated stateVector object

% Defaults
if ~exist('verbose','var') || isempty(verbose)
    verbose = obj.verbose;
end
if ~exist('warn','var') || isempty(warn)
    warn = obj.warn;
end

% Error check
dash.assertScalarLogical(verbose, 'verbose');
dash.assertScalarLogical(warn, 'warn');

% Set values
obj.verbose = verbose;
obj.warn = warn;

end