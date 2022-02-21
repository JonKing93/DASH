function[] = dispAdjustments(fill, range, transformType, transformParams)
%% gridfile.dispAdjustments  Prints data adjustments to the console
% ----------
%   gridfile.dispAdjustments(fill, range, transformType, transformParams)
%   Prints information about data adjustments to the console.
% ----------
%   Inputs:
%       fill (numeric scalar): A fill value for a dataset
%       range (numeric vector [2]): The valid range of a data set
%       transformType (string scalar): The transformation to use for a data set
%       transformParams (numeric vector [2]): Parameters to use for data
%           transformations
%
%   Outputs:
%       Prints information about data adjustments to the console.
%
% <a href="matlab:dash.doc('gridfile.dispAdjustments')">Documentation Page</a>

% Parameters
fieldStrings = ["Fill Value","Valid Range","Transform"];
printField = [false false false];

% Get printed fields
if ~isnan(fill)
    printField(1) = true;
end
if ~isequal(range, [-Inf Inf])
    printField(2) = true;
end
if ~strcmp(transformType, "none")
    printField(3) = true;
end

% Exit if not printing anything
if ~any(printField)
    return
end

% Get field width format
fields = fieldStrings(printField);
width = max(strlength(fields));
format = sprintf('    %%%.fs', width);

% Fill value and valid range
if printField(1)
    fprintf([format,': %f\n'], fieldStrings(1), fill);
end
if printField(2)
    fprintf([format,': %f to %f\n'], fieldStrings(2), range(1), range(2));
end

% Transformation
if printField(3)
    if strcmp(transformType, 'log')
        type = 'log(X)';
    elseif strcmp(transformType, 'ln')
        type = 'ln(X)';
    elseif strcmp(transformType, 'log10')
        type = 'log10(X)';
    elseif strcmp(transformType, 'exp')
        type = 'exp(X)';
    elseif strcmp(transformType, 'power')
        type = sprintf('X .^ %f', transformParams(1));
    elseif any(strcmp(transformType, ["plus","add","+"]))
        type = sprintf('X + %f', transformParams(1));
    elseif any(strcmp(transformType, ["times","multiply","*"]))
        type = sprintf('X * %f', transformParams(1));
    elseif strcmp(transformType, 'linear')
        type = sprintf('%f * X + %f', transformParams(1), transformParams(2));
    end 
    fprintf([format,': %s\n'], fieldStrings(3), type);
end

% End block with new line
fprintf('\n');

end