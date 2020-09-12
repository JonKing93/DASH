function[times] = timepoints( obj )
% Gets time metadata for the entire ensemble
%
% times = obj.timepoints

% Find the first variable with non-NaN metadata
[~,~,~,~,~,~,time] = getDimIDs;
hasmeta = false;
for v = 1:numel(obj.varName)
    if ~isnan( obj.stateMeta.(obj.varName(v)).(time) )
        hasmeta = true;
        break;
    end
end

% Preallocate
siz = [obj.varLimit(end), 1];
if ~hasmeta || ~isdatetime( obj.stateMeta.(obj.varName(v)).(time) )
    times = NaN( siz );
else
    times = NaT( siz );
end

% Try to extract time points for each variable
for v = 1:numel(obj.varName)
    try
        times = obj.getTimeSequence( obj.varName(v) );
    catch
        warning('Unable to determine coordinates for variable %s.', obj.varName(v) );
    end
    
    % Replicate over a complete grid
    nIndex = prod(obj.varSize(v,:));
    nRep = nIndex ./ size(times,1);
    times = repmat( times, [nRep,1] );
    
    % Reduce if a partial grid
    if obj.partialGrid(v)
        times = times(obj.partialH{v});
    end
    
    % Concatenate
    try
        times( obj.varIndices(obj.varName(v)) ) = repmat( times, [nRep, 1] );
    catch
        warning('Cannot concatenate time points for variable %s.', obj.varName(v));
    end
end

end
    
    