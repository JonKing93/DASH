function[flags] = vararginFlags(inputs, spacing, nPrevious, header)

% Defaults
if ~exist('header','var') || isempty(header)
    header = 'DASH:parse:vararginFlags';
end
if ~exist('spacing','var') || isempty(spacing)
    spacing = 1;
end
if ~exist('nPrevious','var') || isempty(nPrevious)
    nPrevious = 0;
end

% Preallocate
nFlags = numel(inputs);
flags = strings(nFlags, 1);

% Get the index of each flag in the total set of inputs and parse
for f = 1:nFlags
    inputIndex = nPrevious + (f-1)*spacing + 1;
    inputName = sprintf('Input %.f', inputIndex);
    flags(f) = dash.assert.strflag(inputs{f}, inputName, header);
end

end