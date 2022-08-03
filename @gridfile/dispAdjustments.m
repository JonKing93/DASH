function[] = dispAdjustments(obj, s)
%% gridfile.dispAdjustments  Prints data adjustments to the console
% ----------
%   <strong>obj.dispAdjustments</strong>
%   <strong>obj.dispAdjustments</strong>(0)
%   Prints information about gridfile default data adjustments to the
%   console.
%
%   <strong>obj.dispAdjustments</strong>(s)
%   Prints information about data adjustments for a data source to the
%   console
% ----------
%   Inputs:
%       s (scalar integer): The index of a data source in the gridfile or 0.
%           If 0, prints default data adjustments for the full gridfile. If an
%           index, print data adjustments for the corresponding data source.
%
%   Outputs:
%       Prints information about data adjustments to the console.
%
% <a href="matlab:dash.doc('gridfile.dispAdjustments')">Documentation Page</a>

% Default data adjustments
if ~exist('s','var') || s==0
    fill = obj.fill;
    range = obj.range;
    transformType = obj.transform_;
    transformParams = obj.transform_params;

% Data adjustments for data sources
else
    fill = obj.fillValue('sources', s);
    if isnan(fill)
        fill = obj.fill;
    end

    range = obj.validRange('sources', s);
    if isequal(range, [-Inf, Inf])
        range = obj.range;
    end

    [transformType, transformParams] = obj.transform('sources', s);
    if strcmp(transformType, "none")
        transformType = obj.transform_;
        transformParams = obj.transform_params;
    end
end

% Initialize printed fields
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