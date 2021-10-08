function[keep] = keep(requested, loaded)
%% dash.indices.keep  Identify requested indices in superset of l
%
%   keep = dash.indices.keep(requested, loaded)
%   Takes the linear indices of requested data elements and compares them
%   to the linear indices of loaded data elements. Returns the linear
%   indices of the requested data elements within the loaded set of data.
%
%   <a href="matlab:dash.doc('dash.indices.keep')">Online Documentation</a>

[~, keep] = ismember(requested, loaded);

end