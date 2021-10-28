function[rst] = outputs(header)
%% Markup the Outputs section from function help text
% ----------
%   rst = build.outputs(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       rst (string scalar): reST markup for the Outputs section

rst = build.function.args(header, "Outputs", 'output', 'Output Arguments');
end