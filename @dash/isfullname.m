function[tf] = isfullname(input)
%% Tests whether an input is an absolute file path
%
% tf = dash.isfullname(input)
%
% ----- Inputs -----
%
% input: A value being tested.
%
% ----- Outputs -----
%
% tf: Whether the input is a absolute file path (true) or not (false).

tf = false;
if dash.isstrflag(input) && ~isempty(fileparts(input))
    tf = true;
end

end
