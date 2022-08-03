function[precision] = loadedPrecision(dataTypes)
%% gridfile.loadedPrecision  Return the numerical precision of output loaded from specified data types
% ----------
%   precision = gridfile.loadedPrecision(dataTypes)
%   Returns the numerical precision of gridfile output loaded from data
%   sources that store the specified data types. Returns 'double' if
%   dataTypes includes double, int32, uint32, int64, or uint64, or if
%   dataTypes is empty. Otherwise, returns 'single'.
% ----------
%   Inputs:
%       dataTypes (string vector): The data types of the data sources used
%           to load a gridfile array.
%
%   Outputs:
%       precision ('single' | 'double'): The numerical precision of the
%           loaded gridfile array
%
% <a href="matlab:dash.doc('gridfile.loadedPrecision')">Documentation Page</a>

if isempty(dataTypes) || any(ismember(dataTypes, ["double","int32","uint32","int64","uint64"]))
    precision = 'double';
else
    precision = 'single';
end

end
