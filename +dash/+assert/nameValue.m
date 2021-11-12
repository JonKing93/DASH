function[names, values] = nameValue(inputs, nPrevious, extraInfo, header)

% Defaults
if ~exist('nPrevious','var') || isempty(nPrevious)
    nPrevious = 0;
end
if ~exist('extraInfo','var') || isempty(extraInfo)
    extraInfo = '';
end
if ~exist('header','var') || isempty(header)
    header = "DASH:assert:nameValue";
end

% Throw error if there are an odd number of inputs
if mod(numel(inputs),2)~=0
    id = sprintf('%s:oddNumberOfInputs', header);
    countInfo = '';
    if nPrevious>0
        countInfo = sprintf(' after the first %.f inputs', nPrevious);
    end
    if ~strlength(extraInfo)==0
        extraInfo = sprintf(' (%s)', extraInfo);
    end
    error(id, 'You must provide an even number of inputs%s.%s', countInfo, extraInfo);
end

% Get the names and values
names = dash.parse.vararginFlags(inputs(1:2:end-1), 2, nPrevious, header);
values = inputs(2:2:end);

end