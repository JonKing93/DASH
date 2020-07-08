function[] = assertPositiveIntegers(input, allowNaN, allowInf, name)

% Process NaNs
if allowNaN
    input(isnan(input)) = 1;
elseif any(isnan(input),'all')
    error('%s may not contain NaN.', name);
end

% Process Inf
if allowInf
    input(isinf(input)) = 1;
elseif any(isinf(input),'all')
    error('%s may not contain Inf.', name);
end

% Everything else
if ~isnumeric(input) || ~isreal(input) || any(input<1,'all') || any(mod(input,1)~=0,'all')
    error('%s can only contain positive integers.', name);
end
    
end