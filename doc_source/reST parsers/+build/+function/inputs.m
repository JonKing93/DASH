function[rst] = inputs(header)
%% Markup the Inputs section from function help text
% ----------
%   rst = build.inputs(header)
% ----------
%   Inputs:
%       header (char vector): Function help text
%
%   Outputs:
%       rst (string scalar): reST markup for the Inputs section

rst = build.function.args(header, "Inputs", 'input', "Input Arguments");
end