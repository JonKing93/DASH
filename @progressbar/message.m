function[message] = message(obj, x)
message = sprintf('%s (%.1f%%)', obj.title, 100*x);
end