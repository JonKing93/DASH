function[sources] = review(obj)
%% Error checks a .grid file prior to repeated loads. (The motivation for 
% this method is to remove duplicate error checks during repeated load
% operations.) Returns a cell array of pre-built data sources for
% subsequent repeated load operations.
%
% sources = obj.review
%
% ----- Outputs -----
%
% sources: A cell vector of pre-built dataSource objects.

% Pre-build the dataSource objects. This will check the sources are still
% valid. Also check the size and data type match the .grid file record.
s = 1:size(obj.fieldLength,1);
sources = obj.buildSources(s);
obj.checkSourcesMatchGrid(sources, s);

end