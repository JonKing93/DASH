function[time] = getTimeSequence( obj, varName )
% Gets the time metadata for one sequence element of a variable in an
% ensemble.
%
% time = obj.getTimeMetadata( varName )

% Dimension names, variable index
[~,~,~,~,~,~,time] = getDimIDs;
v = obj.varCheck(varName);

% Sub-index the metadata for a complete grid
nEls = obj.varSize(v,5);
time = obj.stateMeta.(obj.varName(v)).(time)(1:nEls,:,:);

end
