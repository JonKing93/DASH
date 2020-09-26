function[meta] = dimension(obj, dim, rows)
%% Returns the metadata for a dimension down the entire state vector.
%
% meta = obj.dimension(dim)
% metaStruct = obj.dimension(dim)
% Returns the metadata for a dimension down the state vector. If the
% state vector variables have compatible metadata, output will be an array
% with one row per state vector. Metadata for dimensional means will be
% along the third dimension. If the variables do not have compatible
% metadata, then output will be a structure with the metadata for each
% variable.
%
% [...] = obj.dimension(dim, rows)
% Only returns dimensional metadata at the requested rows
%
% ----- Inputs -----
%
% dim: The name of a dimension in a state vector ensemble. A string.
%
% rows: ...

% Error check
dim = dash.assertStrFlag(dim, 'dim');

% Record whether a variable has the dimension
nVars = numel(obj.variableNames);
hasdim = false(nVars, 1);

% Note if each variable has the dimension. Get state metadata if so
metaCell = cell(nVars,1);
for v = 1:nVars
    if ismember(dim, obj.dims{v})
        metaCell{v} = obj.variable(obj.variableNames(v), dim, 'state');
        hasdim(v) = true;

    % If the variable doesn't have the dimension, use NaN metadata
    else
        metaCell{v} = NaN(obj.nEls(v), 1);
    end
end

% Try to concatenate the metadata values in the structure.
try
    meta = cat(1, metaCell{hasdim});

    % If any variables are missing the dimension, get the details of the
    % successfully concatenated array
    if any(~hasdim)
        siz = [size(meta,2), size(meta,3)];
        if isnumeric(meta)
            type = 'numeric';
        elseif isdatetime(meta)
            type = 'datetime';
        elseif isstring(meta) || iscellstr(meta) || ischar(meta)
            type = 'string';
        end

        % Infill the missing metadata
        for v = 1:nVars
            if ~hasdim(v)
                metaSize = [obj.nEls(v), siz];
                if strcmp(type, 'numeric')
                    metaCell{v} = NaN(metaSize);
                elseif strcmp(type, 'datetime')
                    metaCell{v} = NaT(metaSize);
                else
                    metaCell{v} = strings(metaSize);
                end
            end
        end

        % Construct the complete metadata array
        meta = cat(1, metaCell{hasdim});
    end

% If the concatenations were unsuccessful, return as a structure
catch
    inputCell = cell(nVars*2, 1);
    inputCell(1:2:end-1) = cellstr(obj.variableNames);
    inputCell(2:2:end) = metaCell;
    meta = struct(inputCell{:});
end

end