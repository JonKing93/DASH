function[sources] = sources(obj)
%% gridfile.sources  Returns the ordered list of data sources in a gridfile
% ----------
sources = obj.sources_.absolutePaths;
end