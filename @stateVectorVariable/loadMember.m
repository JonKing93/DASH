function[Xm, sources] = loadMember(obj, subMember, s, grid, sources)
%% Loads a single ensemble member for a stateVectorVariable
%
% [Xm, sources] = obj.loadMember(subMember, s, grid, sources)
%
% ----- Inputs -----
%
% subMember: The subscripted ensemble dimensions for the ensemble member
%
% s: A loadSettings structure
%
% grid: A gridfile object for the variable
%
% sources: A vector of dataSources for the variable
%
% ----- Outputs -----
%
% Xm: The loaded ensemble member. A column vector
%
% sources: The dataSources updated with any newly build dataSource objects

% Get the load indices for the ensemble dimensions
for k = 1:numel(s.d)
    i = s.d(k);
    s.indices{i} = obj.indices{i}(subMember(k)) + s.addIndices{k};
end
nDims = numel(obj.dims);

% Load the data for the ensemble member. Reshape sequence elements to be
% separate from mean elements.
[Xm, ~, sources] = grid.repeatedLoad(1:nDims, s.indices, sources);
Xm = reshape(Xm, s.siz);

% If taking a mean over a dimension, get the weights
for k = 1:nDims
    if obj.takeMean(k)
        w = obj.weightCell{k};
        
        % If omitting NaN, propagate weights over matrix and infill NaN
        if obj.omitnan(k)
            nanIndex = isnan(Xm);
            if any(nanIndex, 'all')
                wSize = s.siz;
                wSize( s.meanDims(obj.takeMean(1:k)) ) = 1;
                w = repmat(w, wSize);
                w(nanIndex) = NaN;
            end
        end
        
        % Take the weighted mean
        Xm = sum(w.*Xm, s.meanDims(k), s.nanflag(k)) ./ sum(w, s.meanDims(k), s.nanflag(k));
    end
end

% Convert to state vector
Xm = Xm(:);

end