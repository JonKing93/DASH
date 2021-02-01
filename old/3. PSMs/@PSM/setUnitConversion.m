function[] = setUnitConversion( obj, varargin )
% Set unit conversion parameters for a PSM
%
% obj.unitConversion( ..., 'times', C )
% Specifies multiplicative constans to apply for unit conversion.
% 
% obj.unitConversion( ..., 'add', C )
% Specifies additive constants to apply for unit conversion.
%
% ***Note: You cannot call this function before generating state indices.

% Need to check length, don't allow before state indices
if isempty( obj.H )
    error('Cannot set unit conversion values until state indices (H) have been generated.');
end

% Parse, error check
[add, mult] = parseInputs( varargin, {'add', 'times'}, {[],[]}, {[],[]} );
nH = numel(obj.H);
if ~isempty(add) && ( ~isvector(add) || ~isnumeric(add) || length(add)~=nH )
    error('The additive unit conversion values must be a numeric vector with one element per state index (%.f).', nH);
elseif ~isempty(mult) && (~isvector(mult) || ~isnumeric(mult))
    error('The multiplicative unit conversion values must be a numeric vector with one element per state index (%.f).', nH);
end

% Convert to column
add = add(:);
mult = mult(:);

% Set the values
obj.addUnit = add;
obj.multUnit = mult;

end