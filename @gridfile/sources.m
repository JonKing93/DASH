function[sources] = sources(obj, s)
%% gridfile.sources  Return the ordered list of data sources in a gridfile
% ----------
%   <strong>obj.sources</strong>
%   Prints the ordered list of data sources to the console
%
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

% Setup
header = "DASH:gridfile:sources";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Console display
if ~exist('s','var') && nargout==0
    if obj.nSource==0
        fprintf('\n    The gridfile "%s" has no data sources.\n\n', obj.name);
    else
        fprintf('\n    Data Sources in gridfile "%s":\n', obj.name);
        obj.dispSources;
    end
    return
end

% Parse indices
if ~exist('s','var') || isempty(s) || isequal(s,0)
    input = {};
else
    logicalRequirement = 'have one element per data source';
    linearMax = 'the number of data sources';
    s = dash.assert.indices(s, obj.nSource, 's', logicalRequirement, linearMax, header);
    input = {obj.sources_.indices(s)};
end

% List sources
sources = obj.sources_.absolutePaths( input{:} );

end