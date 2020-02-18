function[time] = getTimeMetadata( obj, varName )
% Gets the time metadata for one sequence element of a variable in an
% ensemble.
%
% time = obj.getTimeMetadata( varName )

% Dimension names, variable index
[~,~,~,~,~,~,time] = getDimIDs;
v = obj.varCheck(varName);
varName = string(varName);

% Get the state indices
H = obj.varIndices( varName );
H = H(1:obj.varSize(v,5));
time = obj.lookup( time, H );

end
