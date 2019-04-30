function[] = buildEnsemble( design, nEns, file )
%% Builds an ensemble from a state vector design and writes it to a .ens file.
%
% buildEnsemble( design, nEns, file )
% Builds a model ensemble. This is the prior for data assimilation.
%
% ----- Inputs -----
%
% design: A state vector design
%
% nEns: The number of ensemble members desired
%
% file: The name of the file into which the model ensemble should be written.
%       Must end with a ".ens" extension.
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