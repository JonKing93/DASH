function[] = remove(obj, sources)
%% gridfile.remove  Remove data sources from a .grid file's catalogue
% ----------
%   <strong>obj.remove</strong>(s)
%   <strong>obj.remove</strong>(sourceNames)
%   Removes the specified data sources from the gridfile.
%
%   <strong>obj.remove</strong>(-1)
%   Removes all data sources from the gridfile.
% ----------
%   Inputs:
%       s (logical vector [nSources] | vector, linear indices): The indices
%           of the data sources that should be removed.
%       sourceNames (string vector): The names of the data sources that
%           should be removed.
%
% <a href="matlab:dash.doc('gridfile.remove')">Documentation Page</a>

% Setup
header = "DASH:gridfile:remove";
dash.assert.scalarObj(obj, header);
obj.assertValid(header);
obj.update;

% Get data source indices
if isequal(sources,-1)
    s = 1:obj.nSource;
else
    s = obj.sources_.indices(sources, header);
end

% Remove the sources
obj.dimLimit(:,:,s) = [];
obj.sources_ = obj.sources_.remove(s);
obj.nSource = size(obj.dimLimit, 3);

% Save
obj.save;

end




