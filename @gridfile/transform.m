function[obj] = transform(obj, 

% obj = obj.transform("ln")
% obj = obj.transform("log")
% obj = obj.transform("log", "e")
% Apply the natural logarithm to all data loaded from the .grid file.
%
% obj = obj.transform("log", 10)
% Apply a base-10 logarithm to all data loaded from the .grid file data
% source
%
% obj = obj.transform("exp")
% Take the exponential of all data loaded from the .grid file data sources
%
% obj = obj.transform("power", k)
% obj = obj.transform("^", k)
% 
% obj = obj.transform("plus", a)
% obj = obj.transform("times", x)
% obj = obj.transform("linear", xa)
%
% obj = obj.transform(sourceNames, ...)
% obj = obj.transform(s, ...)
% Only transform data loaded from the specified data sources.