function[keep] = keep(requested, loaded)
%% dash.indices.keep  Identify requested indices in superset of loaded indices
% ----------
%   keep = dash.indices.keep(requested, loaded)
%   Takes the linear indices of requested data elements and compares them
%   to the linear indices of loaded data elements. Returns the linear
%   indices of the requested data elements within the loaded set of data.
% ----------
%   Inputs:
%       requested (vector, linear indices): Indices of requested data
%           elements within a dataset
%       loaded (vector, linear indices): Indices of loaded data elements
%           from a dataset
%
%   Outputs:
%       keep (vector, linear indices): Indices of requested data elements
%           within the loaded data set
%
%   <a href="matlab:dash.doc('dash.indices.keep')">Documentation Page</a>

[~, keep] = ismember(requested, loaded);

end