function[sObs, sActive, sFinal, nPrev] = seasonSetup(obSeason)
% Formats inputs for seasonally sensitive observations.
% 
%
% ----- Inputs -----
%
% obSeason: A matrix that indicates the seasonal sensitivity of each
% observation. Please see Season_Format.txt for how to create this matrix.
%
%
% ---- Outputs -----
%
% sObs: An index that notes which observational set each observation site
% belongs to.
%
% sFinal: The final recording season for each observational set.
%
% nPrev: The number of previous states recorded in each observational set.
%
% sActive: A cell containing the time indices of all active seasons
% relative to the final recording season.

% !!! Should implement some error checking

% Get the number of observation types
[obSets, ~, sObs] = unique(obSeason,'rows');
nSets = size(obSets,1);
nSeas = size(obSets,2);

% !!!!!
% To do averaging over multiple cycles, you would need to increase the
% number of columns in obSeason, for example, to every two years. Although
% this probably wouldn't work well with the cyclic -> seasonal time
% conversion.

% Get the season on which each set ends. Also get time indices of each
% active season relative to the final season. Also record the number of
% previous states needed for each record.
sFinal = NaN(nSets,1);
sActive = cell(nSets,1);
nPrev = NaN(nSets,1);

for s = 1:nSets
    sFinal(s) = find( obSets(s,:)==max(obSets(s,:)) );
    
    % Get recording seasons for each observational set
    sActive{s} = find( obSets(s,:) );
    
    % Get time indices of each active season relative to the final season.
    sActive{s} = sort(  mod( sActive{s}-sFinal(s), -nSeas )  );
    
    % Get the maximum number of previous states
    nPrev(s) = abs( min(sActive{s}) );
end

end