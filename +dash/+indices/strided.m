function[indices] = strided(indices)
%% dash.indices.strided  Equally spaced indices that include all input indices
% ----------
%   B = dash.indices.strided(A)
%   Returns a set of equally spaced, monotonically increasing indices (B)
%   that contain all linear indices specified in A.
% ----------
%   Inputs:
%        A (vector, linear indices)
%
%   Outputs:
%       B (vector, linear indices): Equally spaced set of indices that
%           includes all indices in A
%
%   <a href="matlab:dash.doc('dash.indices.strided')">Documentation Page</a>

% Sort indices and get spacing
if numel(indices)>1
    indices = sort(indices);
    if numel(indices)>2
        spacing = unique(diff(indices));

        % Use largest stride possible that includes all indices
        if numel(spacing)>1
            stride = 1;
            if all( mod(spacing(2:end), spacing(1))==0 )
                stride = spacing(1);
            end
            indices = indices(1):stride:indices(end);
        end
    end
end

end