function[] = addToEnsemble( file, nNew )
%% Adds additional ensemble members to a previously built ensemble. Will
% only select new ensemble members -- does not allow repeat draws.
%
% addToEnsemble( file, nNew )
%
% ----- Inputs -----
%
% file: The name of the .ens file containing the ensemble that should be
%       given additional ensemble members.
%
% nNew: The number of new ensemble members to add.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Error check the file. Get a matfile object
m = ensFileCheck( file, 'add' );

% Ensure that the number of new ensemble members is a positive integer
if ~isnumeric(nNew) || ~isscalar(nNew) || nNew < 1 || mod(nNew,1)~=0
    error('nNew must be a positive, scalar integer.');
end

% Get the state vector design
design = m.design;

% Check that the design is still valid
reviewDesign( design );

% Get the new draws
newDesign = drawEnsemble( design, nNew, false );

% Get the size of the original ensemble
ensSize = m.ensSize;

% Add the new draws to the ensemble.
try
    addWriteEnsemble( m, newDesign, nNew );
    
% If an error is thrown, restore the .ens file to its original state.
catch
    
    % Get the current size of M
    newSize = size( m.M, 2 );
    
    % Delete any columns past the original size
    delete = ensSize(2)+1 : newSize;
    m.M(:, delete) = [];
    
    % Revert the metadata
    m.design = design;
    m.ensSize = ensSize;
end

end
