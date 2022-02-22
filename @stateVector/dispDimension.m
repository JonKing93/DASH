function[] = dispDimension(info, showAllDetails)

% Indices and description
if strcmp(info.type,'state')
    nIndices = numel(info.state_indices);
    type = 'state';
elseif strcmp(info.type, 'ensemble')
    nIndices = numel(info.reference_indices);
    type = 'reference';
end

% Dimension name, type, length, number of indices
fprintf('    <strong>Dimension: %s</strong>\n', info.name);
fprintf('           Type: %s\n', cap(info.type));
fprintf('         Length: %.f\n', info.length);
fprintf('        Indices: %.f  (%s indices)\n\n', nIndices, type);

% 
if ~showAllDetails
    printConcise(info);
else
    printVerbose(info);
end

end

% Utilities
function[str] = cap(str)
str(1) = upper(str(1));
end
function[] = printConcise(info)

% Initialize fields
fields = ["Mean","Sequence","Metadata"];
printField = [false, false, false];

% Get fields to print
if ~strcmp(info.mean.type, 'none')
    printField(1) = true;
end
if ~isempty(info.sequence)
    printField(2) = true;
end
if ~strcmp(info.metadata.type, 'raw')
    printField(3) = true;
end

% Exit if no fields
if ~any(printField)
    return
end

% Get width format
width = max(strlength(fields(printField)));
format = sprintf('        %%%.fs: %%s\\n', width);

% Print fields
if printField(1)
    fprintf(format, fields(1), cap(info.mean.type));
end
if printField(2)
    fprintf(format, fields(2), 'True');
end
if printField(3)
    fprintf(format, fields(3), cap(info.metadata.type));
end

% End block with newline
fprintf('\n');

end
function[] = printVerbose(info)

% Mean
fprintf('        Mean: %s\n', cap(info.mean.type));
if strcmp(info.mean.type, 'none')
    fprintf('\n');
else
    fprintf('            NaN Flag: %s\n', info.mean.nanflag);
    if isfield(info.mean, 'indices')
        fprintf('             Indices:');
        disp(info.mean.indices');
    else
        fprintf('\n');
    end
end

% Sequence
if isempty(info.sequence)
    fprintf('        Sequence: False\n\n');
else
    fprintf('        Sequence: True\n');
    siz = size(info.sequence.metadata);
    type = class(info.sequence.metadata);
    fprintf('            Metadata: [%.fx%.f %s]\n', siz(1), siz(2), type);
    fprintf('             Indices:');
    disp(info.sequence.indices');
end

% Metadata
type = info.metadata.type;
fprintf('        Metadata: %s\n', cap(type));
if strcmp(type, 'raw')
    fprintf('\n');
elseif strcmp(type, 'alternate')
    siz = size(info.metadata.values);
    type = class(info.metadata.values);
    fprintf('            Values: [%.fx%.f %s]\n\n', siz(1), siz(2), type);
elseif strcmp(type, 'convert')
    fprintf('            Function: %s\n', func2str(info.metadata.function));
    if isfield(info.metadata, 'args')
        fprintf('                Args:');
        disp(info.metadata.args);
    else
        fprintf('\n');
    end
end

end