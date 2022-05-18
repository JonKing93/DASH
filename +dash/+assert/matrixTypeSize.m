function[] = matrixTypeSize(input, types, siz, name, header)
%% dash.assert.matrixTypeSize  Throw error if input is not a matrix of a specified format
% ----------
%   dash.assert.matrixTypeSize(input, types, siz)
%   Checks if an input is a matrix of the required data type and size. If
%   not, throws an error.
%
%   dash.assert.matrixTypeSize(input, types, siz, name, header)
%   Customize error messages and IDs.
% ----------
%   Inputs:
%       input: The input being tested
%       types (string vector | []): The allowed data types of the input.
%           Use an empty array to allow any type.
%       siz (vector, positive integers [2] | []): The required size of the
%           matrix. The first element is required number of rows, and the
%           second element is the required number of columns. Use NaN for
%           an element to allow any size along that dimension, or use an
%           empty array to allow any size.
%       name (string scalar): The name of the input for error messages.
%           Default is "input".
%       header (string scalar): Header for thrown error IDs.
%
% <a href="matlab:dash.doc('dash.assert.matrixTypeSize')">Documentation Page</a>

% Defaults
if ~exist('name','var') || isempty(name)
    name = "input";
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:matrixTypeSize";
end

% Matrix
try
    if ~ismatrix(input)
        id = sprintf('%s:inputNotMatrix', header);
        error(id, '%s must be a matrix', name);
    end

    % Type
    if ~isempty(types)
        dash.assert.type(input, types, name, "matrix", header);
    end

    % Size
    if ~isempty(siz)
        [nRows, nCols] = size(input);
        if ~isnan(siz(1)) && nRows~=siz(1)
            id = sprintf('%s:wrongNumberOfRows', header);
            error(id, '%s must have %.f rows, but it has %.f rows instead',...
                name, siz(1), nRows);
        elseif ~isnan(siz(2)) && nCols~=siz(2)
            id = sprintf('%s:wrongNumberOfColumns', header);
            error(id, '%s must have %.f columns, but it has %.f columns instead',...
                name, siz(2), nCols);
        end
    end

% Minimize error stack
catch ME
    throwAsCaller(ME);
end

end