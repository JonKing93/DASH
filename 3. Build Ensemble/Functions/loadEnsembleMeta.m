function[ensMeta, design, ensSize] = loadEnsembleMeta( file )
%% Loads metadata associated with a .ens file.
%
% [ensMeta, design, ensSize] = loadEnsembleMeta( file )
%
% ----- Inputs -----
%
% file: a .ens file (created by "buildEnsemble.m")

% Check for .ens file. Get matfile object.
m = ensFileCheck(file);

% Load the variables
design = m.design;
ensMeta = m.ensMeta;
ensSize = m.ensSize;

end