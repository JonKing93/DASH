function[sources] = sources(obj)
%% gridfile.sources  Return the ordered list of data sources in a gridfile
% ----------
%   sources = <strong>obj.sources</strong>
%   sources = <strong>obj.sources</strong>([])
%   sources = <strong>obj.sources</strong>(0)
%   Returns the ordered list of data sources in a gridfile. The index of
%   each data source in the list corresponds to the index of the data
%   source in the gridfile.
%
%   sources = <strong>obj.sources</strong>(s)
%   Returns the list of data sources at the specified data source indices.
%   The order of sources in the list corresponds to the order of input
%   indices.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be returned in the list.
%
%   Outputs:
%       sources (string vector): The list of data sources.
%
% <a href="matlab:dash.doc('gridfile.sources')">Documentation Page</a>
sources = obj.sources_.absolutePaths;
end