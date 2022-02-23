function[length] = length(obj)
%% stateVector.length  Return the length of a state vector
% ----------
%   length = <strong>obj.length</strong>
%   Returns the number of elements in the state vector.
% ----------
%   Outputs:
%       length (scalar positive integer): The number of elements in the
%           state vector.
%
% <a href="matlab:dash.doc('stateVector.length')">Documentation Page</a>

length = 0;
for v = 1:obj.nVariables
    sizes = obj.variables_(v).stateSizes;
    if ~isempty(sizes)
        length = length + prod(sizes);
    end
end

end