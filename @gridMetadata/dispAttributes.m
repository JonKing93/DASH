function[] = dispAttributes(obj)
%% gridMetadata.dispAttributes  Display metadata attributes in the console
% ----------
%   <strong>obj.dispAttributes</strong>
%   Prints the metadata attributes to the console
% ----------
%
% <a href="matlab:dash.doc('gridMetadata.dispAttributes')">Documentation Page</a>

dash.assert.scalarObj(obj, 'DASH:gridMetadata:dispAttributes');
[~, atts] = obj.dimensions;
disp(obj.(atts));

end