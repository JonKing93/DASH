function[sObs, sFinal, nPrev, sRecord] = seasonSetup(obSeason)
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
% sRecord: A cell containing the time indices of all active seasons
% relative to the final recording season.

% !!! Should implement some error checking

% Get the number of observation types
[obSets, ~, sObs] = unique(obSeason,'rows');
nSets = size(obSets,1);
nSeas = size(obSets,2);

% !!!!!
% To do averaging over multiple cycles, you would need to increase the
% number of columns in obSeason, for example, to every two years

% Get the number of previous states used in each cycle
nPrev = max(obSets,[],2)-1;

% Get the season that each set ends on
sFinal = NaN(nSets,1);
sRecord = cell(nSets,1);

for s = 1:nSets
    sFinal(s) = find( obSets(s,:)==max(obSets(s,:)) );
    
    % Get recording seasons for each observational set
    sRecord{s} = find( obSets(s,:) );
    
    % Get time indices of each active season relative to the final season.
    sRecord{s} = sort(  mod( sRecord{s}-sFinal(s), -nSeas )  );
    
end

end