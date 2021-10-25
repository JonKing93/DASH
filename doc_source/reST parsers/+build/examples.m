function[rst] = examples(file)
%% Markup the examples section from an examples file
% ----------
%   rst = build.examples(file)
% ----------
%   Inputs:
%       file (string scalar): Name of an examples file
%
%   Outputs:
%       rst (string scalar): reST markup for the Examples section


% Only parse if file exists
if ~exist('file','var') || isempty(file)
    rst = '';
    return;
end

% Get the examples and accordion handles
[labels, details] = parse.examples(file);
handles = link.handles('example', numel(labels));

% Format
rst = format.examples(labels, details, handles);

end