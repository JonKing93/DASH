function[obj] = saveDraws( obj, cv, subDraws )
% Save the draws for each set of coupled variables.

% Get the ensemble dimensions
var1 = obj.var( cv(1) );
ensDim = find( ~var1.isState );

% Save the values
for v = 1:numel(cv)
    for d = 1:numel(ensDim)
        obj.var( cv(v) ).drawDex{ensDim(d)} = subDraws(:,d);
    end
end

end