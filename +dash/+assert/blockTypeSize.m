function[] = blockTypeSize(input, types, siz, name, header)
%% dash.assert.blockTypeSize  Throw error if input is not a 3D array of a specified format
% ----------
%   dash.assert.blockTypeSize(input, types, siz)
%   Checks if an input is a 3D array of the required data type and size. If
%   not, throws an error.
%
%   dash.assert.blockTypeSize(input, types, siz, name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       types (string vector | []): The allowed data types of the input.
%           Use an empty array to allow any type.
%       siz (vector, positive integers [3] | []): The required size of the
%           3D array. Use NaN for an element to allow any size along that
%           dimension, or use an empty array to allow any size.
%       name (string scalar): The name of the input for error messages.
%           Default is "input".
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.assert.blockTypeSize')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:blockTypeSize";
end

% Matrix
try
    if ndims(input) > 3
        id = sprintf('%s:inputNotMatrix', header);
        error(id, '%s cannot have more than 3 dimensions', name);
    end

    % Type
    if ~isempty(types)
        dash.assert.type(input, types, name, "3D array", header);
    end

    % Size
    if ~isempty(siz)
        [nRows, nCols, nPages] = size(input);
        if ~isnan(siz(1)) && nRows~=siz(1)
            id = sprintf('%s:wrongNumberOfRows', header);
            error(id, '%s must have %.f rows, but it has %.f rows instead',...
                name, siz(1), nRows);
        elseif ~isnan(siz(2)) && nCols~=siz(2)
            id = sprintf('%s:wrongNumberOfColumns', header);
            error(id, '%s must have %.f columns, but it has %.f columns instead',...
                name, siz(2), nCols);
        elseif ~isnan(siz(3)) && nPages~=siz(3)
            id = sprintf('%s:wrongNumberOfPages', header);
            error(id, ['%s must have %.f elements along the third dimension, but it ',...
                'has %.f elements instead'], name, siz(3), nPages);
        end
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end