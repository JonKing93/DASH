function[] = buildEnsemble( design, nEns, file )
%% Builds an ensemble from a state vector design
%
% buildEnsemble( design, nEns )
% Builds a prior model ensemble.
% 
%
% ----- Inputs -----
%
% design: A state vector design
%
% nEns: The number of ensemble members
%
% ----- Outputs -----
%
% M: The ensemble
%
% ensMeta: Metadata for each state element.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check, get the .ens object
m = setup(file, nEns);

% Error check the design
reviewDesign(design);

% Couple ensemble indices
design = coupleIndices( design );

% Draw the ensemble members
design = drawEnsemble( design, nEns, true );

% Create the .ens file
writeEnsemble( m, design, nEns );

end

function[m] = setup( file, nEns )

% Check that nEns is a positive integer
if ~isscalar(nEns) || nEns < 1 || mod(nEns,1)~=0
    error('nEns must be a scalar positive integer.');
end

% Check the file path and extension
m = ensFileCheck( file, 'new' );

end