function[ensMeta, design, ensSize] = loadEnsembleMeta( file )
%% Loads metadata associated with a .ens file.
%
% [ensMeta, design, ensSize] = loadEnsembleMeta( file )
%
% ----- Inputs -----
%
% file: a .ens file (created by "buildEnsemble.m")

% Check for .ens file. Get matfile object.
m = ensFileCheck(file, 'load');

% Load the design
design = m.design;

% Generate the metadata. Doing this dynamically because adding cells to the
% .ens matfile causes a huuuuuuuge reduction in speed. It's much much much
% faster to dynamically generate the metadata each time, rather than trying
% to save it to file.
ensMeta = ensembleMetadata( design );

% Also get the ensemble size
ensSize = m.ensSize;

end