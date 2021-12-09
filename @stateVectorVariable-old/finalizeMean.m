function[obj] = finalizeMean(obj)
%% Finalizes the options for taking means for a state vector variable. Sets
% default meanSize, and weights, and permutes weights for later singleton
% expansion.
%
% obj = obj.finalizeMean;
%
% ----- Outputs -----
%
% obj: The finalized stateVectorVariable

% Default size for no mean
obj.meanSize(isnan(obj.meanSize)) = 1;

% Default weights
for d = 1:numel(obj.dims)
    if obj.takeMean(d)
        if isempty(obj.weightCell{d})
            obj.weightCell{d} = ones(obj.meanSize(d), 1);
        end
        
        % Permute for singleton expansion
        order = 1:max(2,d);
        order(d) = 1;
        order(1) = d;
        obj.weightCell{d} = permute(obj.weightCell{d}, order);
    end
end

end