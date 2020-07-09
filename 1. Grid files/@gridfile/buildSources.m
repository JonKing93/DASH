function[sources] = buildSources(obj, s)
filenames = obj.collectPrimitives("file", s);
sources = obj.buildSourcesForFiles(s, filenames);
end