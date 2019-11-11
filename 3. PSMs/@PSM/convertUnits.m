function[M] = convertUnits( obj, M )
% Converts units via M* = AM + B
%
% M = obj.convertUnits( M )

if ~isempty(obj.multUnit)
    M = M .* obj.multUnit;
end

if ~isempty(obj.addUnit)
    M = M + obj.addUnit;
end

end