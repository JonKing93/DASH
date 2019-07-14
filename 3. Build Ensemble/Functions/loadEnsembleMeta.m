function[ensMeta, design, ensSize] = loadEnsembleMeta( inArg )
%% Loads metadata associated with a .ens file or state design.
%
% [ensMeta, design, ensSize] = loadEnsembleMeta( file )
% Loads the ensemble metadata associated with a .ens file.
%
% [ensMeta] = loadEnsembleMeta( design )
% Loads the ensemble metadata associated with a stateDesign object.
%
% ----- Inputs -----
%
% file: a .ens file containing a model ensemble.
%
% design: A stateDesign object
%
% ----- Outputs -----
%
% ensMeta: Metadata for the ensemble. This is a structure with a field for
%          each dimension. Each dimension consists of a (nState x 1) cell
%          containing the dimensional metadata for each state element.
%
% design: The stateDesign object associated with the ensemble.
%
% ensSize: The size of the ensemble.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Check if this is a stateDesign
if isa(inArg, 'stateDesign')
    design = inArg;
    
    % Return an empty ensemble size
    ensSize = [];
    
% Otherwise, treat as a file
else
    file = inArg;
    
    % Check for .ens file. Get matfile object.
    m = ensFileCheck(file, 'load');

    % Load the design
    design = m.design;
    
    % Also get the ensemble size
    ensSize = m.ensSize;
end

% Generate the metadata. Doing this dynamically because adding cells to the
% .ens matfile causes a huuuuuuuge reduction in speed. It's much much much
% faster to dynamically generate the metadata each time, rather than trying
% to save it to file.
ensMeta = ensembleMetadata( design );

end