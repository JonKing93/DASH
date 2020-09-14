function[X] = padPrimitives( X, maxCol )
%% Pads a primitive array to have a certain number of columns
%
% X = gridfile.padPrimitives( X, maxCol )
%
% ----- Inputs -----
%
% X: A primitive array
%
% maxCol: The number of columns
%
% ----- Outputs -----
%
% X: The padded primitive array.

nCol = size(X,2);
nPad = maxCol - nCol;

pad = NaN;
if ischar(X)
    pad = ' ';
end

X(:, end+(1:nPad)) = pad;

end