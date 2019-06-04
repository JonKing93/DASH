function[tf] = isstrlist( list )
tf = true;
if ~isvector( list )
    tf = false;
elseif ~isstring( list ) && ~iscellstr( list )
    tf = false;
end
end

