function[sizes, types] = stateSizes(obj)
%% dash.stateVectorVariable.stateSizes  Returns the sizes and names of state dimensions
% ----------
%   sizes = <strong>obj.stateSizes</strong>
%   Return the lengths of dimensions with a non-trivial number of state
%   vector elements. Non-trivial dimensions are all state dimensions (even
%   if taking a mean), and ensemble dimensions with sequences.
%
%   [sizes, types] = <strong>obj.stateSizes</strong>
%   Also return a string identifying the dimension and any details
%   associated with each dimension length. For state dimensions, "<dim>". For
%   state dimensions with a mean "<dim> mean". For sequences, uses
%   "<dim> sequence".
% ----------
%   Outputs:
%       sizes (vector, positive integers [nDimensions]): The lengths of all
%           dimensions with a non-trivial state vector length.
%       types (string vector [nDimensions]): Dimension name and details
%           associated with each state vector length.
%
% <a href="matlab:dash.doc('dash.stateVectorVariable.stateSizes')">Documentation Page</a>

% Get non-trivial state dimensions
d = find(obj.isState | obj.hasSequence);

% Empty case
if isempty(d)
    sizes = [];
    types = strings(1,0);
    return
end

% Sizes and dims
sizes = obj.stateSize(d);

% Types (dimension + comment)
if nargout>1
    types = strings(size(d));

    % Sequence
    types(obj.hasSequence(d)) = " sequence";

    % Mean
    ismean = obj.isState(d) & ismember(obj.meanType(d), [1 2]);
    types(ismean) = " mean";

    % Total
    istotal = obj.isState(d) & ismember(obj.meanType(d), [3 4]);
    types(istotal) = " total";

    % Combine dimensions into single string
    types = strcat(obj.dims(d), types);
end

end