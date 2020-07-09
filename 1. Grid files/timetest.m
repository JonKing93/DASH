% Check that gridfile commands work correctly.

% 
% buildTrefLMEGrid;
% % grid = gridfile('tref-lme.grid');
% % 
% % grid.rewriteMetadata('lev', 5);
% % grid.rewriteMetadata('coord', "hello")
% % grid.expand('coord', {'banan'; 'yup'})
% 
% sources = cell(24,1);
% indices = {45:45+11, 5};
% [~,inputOrder] = ismember(["time","run"], grid.dims);
% for k = 1:1000
%     [X, meta] = grid.load(["time","run"], indices);
% end

grid = gridfile('tref-lme.grid');
grid.renameSources;