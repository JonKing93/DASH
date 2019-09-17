function[ens] = buildEnsemble( obj, nEns, random )
%% Builds an ensemble from a state vector design.
%
% ens = obj.buildEnsemble( nEns )
% Builds an ensemble with nEns ensemble members.
%
% ens = obj.buildEnsemble( nEns, random )
% Specifies whether ensemble members should be selected sequentially, or
% drawn at random. Default is random.
%
% ----- Inputs -----
%
% nEns: The number of ensemble members. A positive integer.
%
% random: A scalar logical indicating whether ensemble members should be
%         drawn randomly or sequentially. Default is true (random).
%
% ----- Outputs -----
%
% ens: An ensemble object.

% Error check the inputs. Set defaults. Check if this is a new ensemble
if ~isnumeric(nEns) || ~isscalar(nEns) || mod(nEns,1)~=0 || nEns<=0
    error('nEns must be a positive, scalar integer.');
elseif ~exist('random','var') || isempty(random)
    random = true;
elseif ~isscalar(random) || ~islogical(random)
    error('random must be a scalar logical.');
end

% Trim ensemble indices so that only complete sequences are allowed
obj = obj.trim;

% Restrict ensemble indices of coupled variables to intersecting metadata.
cv = obj.coupledVariables;
for set = 1:numel(cv)
    obj = obj.matchMetadata( cv{set} );
    
    % Initialize values in preparation for making draws. 
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
    obj = obj.saveDraws( cv{set}, subDraws );
end

% Save to an ensemble object
obj.new = false;
ens = ensemble( obj );

end