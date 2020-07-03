function[] = assertPositiveIntegers(input, allowNaN, allowInf, name)
if ~isnumeric(input) || ~isreal(input) || any(input<1,'all') || any(mod(input,1)~=0,'all')
    error('%s can only contain positive integers.');

elseif ~allowNaN && any(isnan(input),'all')
    error('%s may not contain NaN.', name);
    
elseif ~allowInf && any(isinf(input),'all')
    error('%s may not contain Inf.', name);
end
end