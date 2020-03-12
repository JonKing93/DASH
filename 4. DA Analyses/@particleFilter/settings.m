function[] = settings( obj, varargin )
% Specifies settings for a particle filter analysis
%
% obj.settings( ..., 'type', type )
% Specify whether to use a probability weighting or N best particles to
% create the analysis. Default is probability weighting.
%
% obj.settings( ..., 'type', 'bestN', 'N', N )
% Set the number of best particles to use to create the analysis. Default
% of N = 1.
%
% obj.settings( ..., 'big', big )
% Indicate whether to use an alternative algorithm to process ensemble
% too large to fit into active memory by processing particles in batches.
%
% obj.settings( ..., 'big', true, 'batchSize', nEns )
% Specify the number of particles to use per batch. Must be specified by
% the user when using the alternative algorithm for large ensembles.
%
% ----- Inputs -----
%
% type: The method used to create the analysis. A string.
%       'weight' - Uses a probability weighted mean of the particles
%       'bestN' - Take the mean of the N best particles
%
% N: The number of particles to use in the "bestN" method. A scalar,
%    positive integer.
%
% big: A scalar logical indicating whether the ensemble is too large to fit
%      into active memory.
%
% nEns: The number of ensemble members to use for batch processing. A
%       scalar positive integer indicating a number of ensemble members that
%       can fit in active memory simultaneously. Large numbers are typicaly
%       faster.

% Parse inputs
[type, N, big, nEns] = parseInputs( varargin, {'type','N','big','nEns'}, ...
    {obj.type, obj.N, obj.big, obj.nEns}, {[],[],[],[]} );

% Error check
if ~isstrflag(type)
    error('type must be a string scalar, or character row vector.');
elseif ~strcmpi(type,'weight') && ~strcmpi(type,'bestN')
    error('Unrecognized type');
elseif ~isscalar(big) || ~islogical(big)
    error('big must be a scalar logical');
end

if strcmpi(type, 'bestN')
    if isnan(N) || isempty(N)
        N = 1;
    elseif ~isnumeric(N) || ~isscalar(N) || ~isreal(N) || N<=0 || mod(N,1)~=0 || N>obj.nEns
        error('N must be a positive scalar integer, and cannot exceeds the size of the ensemble (%.f)', obj.nEns );
    end
else
    N = NaN;
end  

if big 
    if isnan(nEns) || isempty(nEns)
        error('You must specify the number of ensemble members to process per batch.');
    elseif ~isnumeric(nEns) || ~isscalar(nEns) || ~isreal(nEns) || nEns<=0 || mod(nEns,1)~=1 || nEns>obj.nEns
        error('nEns must be a positive scalar integer, and cannot exceeds the size of the ensemble (%.f)', obj.nEns );
    end
else
    nEns = NaN;
end

% Save the settings
obj.type = type;
obj.N = N;
obj.big = big;
obj.nEns = nEns;

end