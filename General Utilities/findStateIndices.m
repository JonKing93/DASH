function[H] = findStateIndices( siteCoord, stateMeta, vars, timeSpec, levels)

% Lat-lon: Find closest
%
% Vars: Require all time/levels for each var
%
% level: Must find one on each level
%
% time: Must find one for each time

% Get some sizes
nVars = numel(vars);
nTime = numel( timeSpec{2} );
nLev = numel(levels);
nDex = nVars .* nTime .* nLev;

% Preallocate an logical array for levels
levDex = false( nState, nLev );

% For each level, get the index of all variables on that level
for lev = 1:nLev
    levDex(:,lev) = isequal( stateMeta.lev, levels(lev) );
end


% Preallocate a logical array for time specifications
timeDex = false( nState, nTime );

% For each time requirement
for t = 1:nTime
    
    % If using datetime months...
    if strcmpi( timeSpec{1} , 'month' )
        timeDex(:,t) = isdatetime(stateMeta.time) && month(stateMeta.time)==timeSpec{2}(t);
        
    % If using datetime years
    elseif strcmpi( timeSpec{1}, 'year' )
        timeDex(:,t) = isdatetime(stateMeta.time) && month(stateMeta.time)==timeSpec{2}(t);
        
    % If using some other string
    elseif strcmpi( timeSpec{1}, 'string' )
        timeDex(:,t) = strcmpi( stateMeta.time, timeSpec{2}{t} );
        
    else
        error('Unrecognized time specification');
    end
end


% Preallocate the variable indices
varDex = false( nState, nVars );

% Get the indices of each variable
for v = 1:nVars
    varDex(:,v) = strcmpi( stateMeta.var, vars{v} );
end


% If any of the indices are empty, default to true
if isempty(varDex)
    varDex = true(nState, 1);
    nVars = 1;
end
if isempty(timeDex)
    timeDex = true(nState, 1);
    nTime = 1;
end
if isempty(levDex)
    levDex = true(nLev, 1);
    nLev = 1;
end

% Preallocate the output indices
H = NaN( nVars*nTime*nLev, 1 );

% For each variable, time, and level...
hDex = 1;
for v = 1:nVars
    for t = 1:nTime
        for lev = 1:nLev
            
            % Find the indices that satisfy the requirements
            stateDex = varDex(:,v) & timeDex(:,t) & levDex(:,lev);
            
            % If only a single coordinate, done. This is the variable.
            if sum(stateDex) == 1
                H(hDex) = find(stateDex);
                hDex = hDex + 1;
                
            % If no coordinates, the variable does not exist. Throw an
            % error.
            elseif sum(stateDex) == 0
                error('A state variable matching the specifications does not exist.');
                
            % Otherwise, multiple coordinates
            else
                % If at least one state coordinate matching the specifications is non-NaN
                if any(~isnan(stateMeta.lat(stateDex))) && any(~isnan(stateMeta.lon(stateDex)))
                    
                    % Find the closest coordinate to the site coordinates
                    H(hDex) = samplingMatrix( siteCoord, [stateMeta.lat(stateDex), stateMeta.lon(stateDex)], 'linear');
                    hDex = hDex + 1;
                    
                % Otherwise throw an error
                else
                    error('Multiple state variables match the specifications, but their coordinates are all NaN.');
                end
            end
        end
    end
end

end