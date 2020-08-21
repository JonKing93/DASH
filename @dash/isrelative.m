function[tf] = isrelative(name)
% Returns whether a filename is a relative file name.

tf = false;
name = char(name);
if name(1) == '.'
    tf = true;
end

end