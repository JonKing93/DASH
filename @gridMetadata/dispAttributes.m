function[] = dispAttributes(obj)
%% gridMetadata.dispAttributes  Display metadata attributes in the console
% ----------
%   obj.dispAttributes
%   Prints the metadata attributes to the console
% ----------
%
% <a href="matlab:dash.doc('gridMetadata.dispAttributes')">Documentation Page</a>

[~, atts] = obj.dimensions;
disp(obj.(atts));

end