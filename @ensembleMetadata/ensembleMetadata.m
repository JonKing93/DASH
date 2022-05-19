classdef ensembleMetadata

    properties
        %% General

        label_ = "";                    % A label for the metadata

        %% Variables

        nVariables = 0;                 % The number of variables in the state vector ensemble
        variables_ = strings(0,1);      % The names of variables in the state vector ensemble
        lengths = NaN(0,1);             % The number of state vector elements for each variable

        %% State dimensions

        stateDimensions = cell(0,1);    % The names of the dimensions with state elements for each variable
        stateSize = cell(0,1);          % The sizes of the dimensions with state elements for each variable
        stateType = cell(0,1);          % The type of each dimension: 0-state, 1-state mean, 2-sequence
        state = cell(0,1);              % The state metadata for each variable

        %% Ensemble dimensions

        nSets = 0;                      % The number of coupling sets in the ensemble
        couplingSet = NaN(0,1);         % The coupling set associated with each variable
        ensembleDimensions = cell(0,1); % The names of the ensemble dimensions for each coupling set
        nMembers = 0;                   % The number of ensemble members for the ensemble
        ensemble = cell(0,1);           % The ensemble metadata for each coupling set

    end

    methods

        % Labels
        varargout = label(obj, label);
        name = name(obj);

        % Variables
        variableNames = variables(obj, v);
        length = length(obj, variables);
        dimensions = dimensions(obj, variables, type, cellOutput);
        v = variableIndices(obj, variables, allowRepeats, header);
        
        % Return metadata
        metadata = members(obj, dimension, members, variable);
        metadata = rows(obj, dimension, rows, cellOutput);
        metadata = variable(obj, variable, dimension, varargin);

        % Locate rows
        varargout = find(obj, variables, type);
        [variableNames, v] = identify(obj, rows);
        indices = subscriptRows(obj, v, variableRows);

        % Coordinates
        coordinates = getLatLon(obj, v, variableRows, dimensions, columns);
        coordinates = latlon(obj, siteColumns, variables);
        rows = closestLatLon(variable, coordinates, varargin);

        % Regrid
        [V, metadata] = regrid(obj, variable, X, varargin);

        % Manipulate variables
        obj = remove(obj, variables);
        obj = extract(obj, variables);
        obj = append(obj, meta2);

        % Manipulate members
        obj = removeMembers(obj, members);
        obj = extractMembers(obj, members);
        obj = appendMembers(obj, members);

        % Console display
        disp(obj);
        dispVariables(obj);
        dispEnsemble(obj);

    end

    % Constructor
    methods
        function[obj] = ensembleMetadata(svs, labels)
            %% ensembleMetadata.ensembleMetadata  Create a new ensembleMetadata object
            % ----------
            %   obj = ensembleMetadata(sv)
            %   Returns an ensembleMetadata object for the input stateVector object.
            %   The ensembleMetadata object holds the metadata down the state vector,
            %   as well as metadata for any built ensemble members. Note that only
            %   stateVector objects produced as output from the "stateVector.build"
            %   and "stateVector.addMembers" will have ensemble members. The label 
            %   of the each ensembleMetadata object will match the label of the 
            %   stateVector object.
            %
            %   obj = ensembleMetadata(sv, label)
            %   Specify the label that should be applied to the ensembleMetadata object
            % ----------
            %   Inputs:
            %       sv (scalar stateVector objects): The stateVector object for
            %           which to build ensembleMetadata objects.
            %       label (string scalar | cellstring scalar | char row vector):
            %           The label to apply to the ensembleMetadata object
            %
            %   Outputs:
            %       obj (scalar ensembleMetadata objects): The ensembleMetadata
            %           object for the state vector ensemble.
            %
            % <a href="matlab:dash.doc('ensembleMetadata.ensembleMetadata')">Documentation Page</a>

            % Header
            header = "DASH:ensembleMetadata";

            % Error check the state vector objects
            dash.assert.type(svs, "stateVector", 'The first input', 'array', header);
            siz = size(svs);

            % Default and error check labels
            if ~exist('labels','var')
                haveLabels = false;
            else
                haveLabels = true;
                labels = dash.assert.string(labels, 'labels', header);

                % Check matching size
                if ~isequal(size(labels), siz)
                    id = sprintf('%s:labelsDifferentSize', header);
                    error(id, ['The size of the "labels" input (%s) is different than the size of the ',...
                        'first input (%s).'], dash.string.size(size(labels)), dash.string.size(siz));
                end
            end

            % Preallocate array
            obj = repmat(obj, siz);

            % Get the state vector for each ensembleMetadata
            try
                for q = 1:numel(obj)
                    sv = svs(q);

                    % Deserialize if necessary
                    if sv.isserialized
                        sv = sv.deserialize;
                    end
        
                    % Build and validate the gridfile objects
                    [grids, failed, cause] = sv.prepareGrids;
                    if failed
                        gridfileFailedError(cause);
                    end
        
                    % Apply the label
                    if haveLabels
                        obj(q).label_ = labels(q);
                    else
                        obj(q).label_ = sv.label_;
                    end
        
                    % Get the variables and their lengths
                    obj(q).variables_ = sv.variables_;
                    nVariables = numel(sv.variables_);
                    obj(q).nVariables = nVariables;
                    obj(q).lengths = sv.length(-1);
        
                    % Initialize state dimension metadata
                    obj(q).stateDimensions = cell(nVariables, 1);
                    obj(q).stateSize = cell(nVariables, 1);
                    obj(q).stateType = cell(nVariables, 1);
                    obj(q).state = cell(nVariables, 1);
        
                    % Get the svv object and gridfile for each variable
                    for v = 1:nVariables
                        svv = sv.variables_(v);
                        g = grids.whichGrid(v);
                        grid = grids.gridfiles(g);
        
                        % Record the dimensions that have state vector elements.
                        dimensions = find(svv.isState | svv.hasSequence);
                        obj(q).stateDimensions{v} = svv.dims(dimensions);
                        obj(q).stateSize{v} = svv.stateSize(dimensions);
        
                        % Preallocate dimensional metadata
                        nDims = numel(dimensions);
                        obj(q).stateType{v} = NaN(1, nDims);
                        obj(q).state{v} = cell(1, nDims);
        
                        % Cycle through state dimensions
                        for k = 1:nDims
                            d = dimensions(k);
        
                            % Get state dimension metadata.
                            if svv.isState(d)
                                [metadata, failed, cause] = svv.getMetadata(d, grid, header);
                                if failed
                                    metadataFailedError(cause);
                                end
        
                                % Permute if taking a mean. Record type
                                if svv.meanType(d)==0 || obj(q).stateSize{v}(k)==1
                                    obj(q).stateType{v}(k) = 0;
                                else
                                    metadata = permute(metadata, [3 2 1]);
                                    obj(q).stateType{v}(k) = 1;
                                end
        
                            % Get sequence metadata. Record type
                            else
                                metadata = svv.sequenceMetadata{d};
                                obj(q).stateType{v}(k) = 2;
                            end
        
                            % Record the metadata for each dimension
                            obj(q).state{v}{k} = metadata;
                        end
                    end
        
                    % Get the number of members and the coupling sets
                    nMembers = sv.members;
                    obj(q).nMembers = nMembers;
                    info = sv.couplingInfo;
                    nSets = numel(info.sets);
        
                    % Initialize ensemble dimension metadata
                    obj(q).nSets = nSets;
                    obj(q).couplingSet = [info.variables.whichSet]';
                    obj(q).ensembleDimensions = cell(nSets, 1);
                    obj(q).ensemble = cell(nSets, 1);
        
                    % Get the ensemble dimensions for each coupling set
                    for s = 1:nSets
                        set = info.sets(s);
                        dimensions = set.ensDims;
                        obj(q).ensembleDimensions{s} = dimensions;
        
                        % If there are no members, we are finished with the set.
                        % Otherwise, preallocate dimensional metadata
                        if nMembers==0
                            continue;
                        end
                        nDims = numel(dimensions);
                        obj(q).ensemble{s} = cell(1, nDims);
        
                        % Get the leading coupled variable and the indices of its
                        % ensemble dimensions
                        v = set.vars(1);
                        svv = sv.variables_(v);
                        dimensions = set.dims(1,:);
        
                        % Get the gridfile and ensemble members
                        subMembers = sv.subMembers{s};
                        g = grids.whichGrid(v);
                        grid = grids.gridfiles(g);
        
                        % Cycle through ensemble dimensions
                        for k = 1:numel(dimensions)
                            d = dimensions(k);
        
                            % Get metadata along the dimension
                            [metadata, failed, cause] = svv.getMetadata(d, grid, header);
                            if failed
                                metadataFailedError(cause);
                            end
        
                            % Record metadata for the ensemble members
                            members = subMembers(1:nMembers, k);
                            rows = svv.indices{d}(members, :);
                            metadata = metadata(rows,:);
                            obj(q).ensemble{s}{k} = metadata;
                        end
                    end
                end

            % Informative error if failed. Adjust message for scalar vs array
            catch cause
                if isscalar(obj)
                    throw(cause);
                else
                    id = sprintf('%s:couldNotBuildMetadata', header);
                    badlabel = sv.label_;
                    if ~strcmp(badlabel, "")
                        badlabel = strcat(" (", badlabel, ")");
                    end
                    ME = MException(id, ['Could not build the ensembleMetadata object for state ',...
                        'vector %.f%s.'], q, badlabel);
                    ME = addCause(ME, cause);
                    throw(ME);
                end
            end
        end
    end
end