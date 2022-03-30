function[] = draw(obj)
x = obj.count / obj.max;
message = obj.message(x);
waitbar(x, obj.handle, message);
end
