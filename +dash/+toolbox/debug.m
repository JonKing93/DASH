function[fullErrors] = debug
%% dash.toolbox.debug  True if the toolbox should return full error stacks
% ----------
%   fullErrors = dash.toolbox.debug
%   Indicates whether the toolbox should return full error stacks or
%   minimal errors. This functions serves as a configuration setting for
%   the toolbox as a whole.
%
%   By default, DASH returns minimal error stacks, which are designed for
%   users not familiar with the toolbox's internal code. By changing the
%   setting in this file from false to true, developers and advanced users
%   can enable full error stacks instead. This can be particularly helpful
%   for debugging the code, as it provides a full traceback of any
%   encountered errors.
% ----------
%   Outputs:
%       fullErrors (scalar logical): True if the toolbox should return full
%           error stacks. False (default) if the toolbox should return
%           minimal error stacks.
%
% <a href="matlab:dash.doc('dash.toolbox.debug')">Documentation Page</a>

fullErrors = false;

end