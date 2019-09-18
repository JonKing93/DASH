function[ens] = buildEnsemble( obj, nEns, file, random, overwrite, writeNaN )
%% Builds an ensemble from a state vector design.
%
% ens = obj.buildEnsemble( nEns, file )
% Builds an ensemble with nEns ensemble members and saves it to file.
%
% ens = obj.buildEnsemble( nEns, file, random )
% Specifies whether ensemble members should be selected sequentially, or
% drawn at random. Default is random.
%
% ens = obj.buildEnsemble( nEns, file, random, overwrite )
% Specify whether the function may overwrite pre-existing files.
%
% ens = obj.buildEnsemble( nEns, file, random, overwrite, writeNaN )
% Specifies whether ensemble members containing NaN should be written to
% file. Default is true.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members. A positive integer.
%
% file: A filename. Must end with a .ens extension.
%
% random: A scalar logical indicating whether ensemble members should be
%         drawn randomly or sequentially. Default is true (random).
%
% overwrite: A scalar logical indicating whether pre-existing files may be
%            overwritten. Default is false.
%
% writeNaN: A scalar logical indicating whether ensemble members containing
%           NaN elements should be written to the .ens file. Default is true.
%
% ----- Outputs -----
%
% ens: An ensemble object.

% Set defaults
if ~exist('random','var') || isempty(random)
    random = true;
end
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end
if ~exist('writeNaN','var') || isempty(writeNaN)
    writeNaN = true;
end

% Error check the inputs.
if ~isnumeric(nEns) || ~isscalar(nEns) || mod(nEns,1)~=0 || nEns<=0
    error('nEns must be a positive, scalar integer.');
elseif ~isscalar(random) || ~islogical(random)
    error('random must be a scalar logical.');
elseif ~isscalar(overwrite) || ~islogical(overwrite)
    error('overwrite must be a scalar logical.');
elseif ~isscalar( writeNaN) || ~islogical( writeNaN )
    error('writeNaN must be a scalar logical.');
end
checkFile( file, 'extension', '.ens' );
if ~overwrite && exist('file','file')
    error('file "%s" already exists.', file);
end

% !!! TODO
if ~writeNaN
    error('writeNaN must be true. Sorry!');
end

% Trim ensemble indices so that only complete sequences are allowed
obj = obj.trim;

% Restrict ensemble indices of coupled variables to intersecting metadata.
cv = obj.coupledVariables;
for set = 1:numel(cv)
    obj = obj.matchMetadata( cv{set} );
    
    % Initialize values in preparation for making draws. 
    nDraws = nEns;
    [overlap, ensSize, undrawn, subDraws] = obj.initializeDraws( cv{set}, nDraws );
    
    % Make draws. Remove overlapping draws if necessary. Continue until
    % the ensemble is complete or impossible.
    while nDraws > 0
        [subDraws, undrawn] = obj.draw( nDraws, subDraws, undrawn, random, ensSize );
        
        if ~overlap
            [subDraws] = obj.removeOverlap( subDraws, cv{set} );
            nDraws = sum( isnan( subDraws(:,1) ) );
        end
    end
    
    % Save the draws for each variable
    obj = obj.saveDraws( cv{set}, subDraws, undrawn );
end

% Write the ensemble to a .ens file. Return the associated ensemble object
obj.write( file, random, writeNaN );
ens = ensemble( file );

end