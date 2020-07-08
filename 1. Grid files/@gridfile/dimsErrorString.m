function[str] = dimsErrorString(dims)
%% Returns a list of dimension names as a string for use in an error message.
%
% str = gridfile.dimsErrorString(dims)
%
% ----- Inputs -----
%
% dims: A list of dimension names. A string vector or cellstring vector.
%
% ----- Ouputs -----
%
% str: A formatted string listing the dimensions.
if numel(dims)==1
    str = sprintf('"%s"',dims);
elseif numel(dims)==2
    str = sprintf('"%s" and "%s"', dims(1), dims(2));
else
    str = [sprintf('"%s", ', dims(1:end-1)), sprintf('and "%s"', dims(end))];
end
end
    