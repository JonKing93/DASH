function[reset] = state(state, warnID)
%% dash.warning.state  Set the state of a warning and restore original state
% ----------
%   reset = dash.warning.state(state, warnID)
%   Sets the state of the indicated warning to a specified value. Allowed
%   values are 'on' (to display as warning), 'off' (to disable a warning),
%   and 'error' (to throw the warning as an error). Returns an onCleanup
%   object that will restore the warning state to its original value when
%   destroyed.
% ----------
%   Inputs:
%       state ('on' | 'off' | 'error'): The desired state of a warning or
%           error message.
%       warnID (string scalar): The identifier of a warning or error message
%
%   Outputs:
%       reset (scalar onCleanup object): An onCleanup object that resets
%           the state to its original value when destroyed.
%
% <a href="matlab:dash.doc('dash.warning.state')">Documentation Page</a>

warn = warning('query', warnID);
warning(state, warnID);
reset = onCleanup(  @()warning(warn.state, warnID)  );

end