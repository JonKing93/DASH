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

        varargout = label(obj, label);
        name = name(obj);

        variableNames = variables(obj, v);
        length = length(obj, variables);
        v = variableIndices(obj, variables, allowRepeats, header);

        obj = remove(obj, variables);
        obj = extract(obj, variables);
        obj = append(obj, meta2);

        obj = removeMembers(obj, members);
        obj = extractMembers(obj, members);
        obj = appendMembers(obj, members);

        metadata = members(obj, dimension, members, variable);
        metadata = rows(obj, dimension, rows, cellOutput);
        metadata = variable(obj, variable, dimension, varargin);

        varargout = find(obj, variables, type);
        [variableNames, v] = identify(obj, rows);

        [V, metadata] = regrid(obj, variable, X, varargin);
        latlon
        closestLatLon
        serialize





    end

    % Constructor
    methods
        function[obj] = ensembleMetadata(sv, label)
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

            % Check the input is a scalar state vector
            header = "DASH:ensembleMetadata";
            dash.assert.scalarType(sv, "stateVector", 'sv', header);

            % Default and parse the label
            if ~exist('label','var')
                label = sv.label;
            else
                label = dash.assert.strflag(label, 'label', header);
            end

            % Build and validate the gridfile objects
            [grids, failed, cause] = sv.prepareGrids;
            if failed
                gridfileFailedError(cause);
            end

            % Apply the label
            obj.label_ = label;

            % Get the variables and their lengths
            obj.variables_ = sv.variables;
            nVariables = numel(obj.variables_);
            obj.nVariables = nVariables;
            obj.lengths = sv.length(-1);

            % Initialize state dimension metadata
            obj.stateDimensions = cell(nVariables, 1);
            obj.stateSize = cell(nVariables, 1);
            obj.stateType = cell(nVariables, 1);
            obj.state = cell(nVariables, 1);

            % Get the svv object and gridfile for each variable
            for v = 1:nVariables
                svv = sv.variables_(v);
                g = grids.whichGrid(v);
                grid = grids.gridfiles(g);

                % Record the dimensions that have state vector elements.
                dimensions = find(svv.isState | svv.hasSequence);
                obj.stateDimensions{v} = svv.dims(dimensions);
                obj.stateSize{v} = svv.stateSize(dimensions);

                % Preallocate dimensional metadata
                nDims = numel(dimensions);
                obj.stateType{v} = NaN(1, nDims);
                obj.state{v} = cell(1, nDims);

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
                        if svv.meanType(d)==0
                            obj.stateType{v}(d) = 0;
                        else
                            metadata = permute(metadata, [3 2 1]);
                            obj.stateType{v}(d) = 1;
                        end

                    % Get sequence metadata. Record type
                    else
                        metadata = svv.sequenceMetadata{d};
                        obj.stateType{v}(d) = 2;
                    end

                    % Record the metadata for each dimension
                    obj.state{v}{d} = metadata;
                end
            end

            % Get the number of members and the coupling sets
            nMembers = sv.members;
            obj.nMembers = nMembers;
            info = sv.couplingInfo;
            nSets = numel(info.sets);

            % Initialize ensemble dimension metadata
            obj.nSets = nSets;
            obj.couplingSet = [info.variables.whichSet]';
            obj.ensembleDimensions = cell(nSets, 1);
            obj.ensemble = cell(nSets, 1);

            % Get the ensemble dimensions for each coupling set
            for s = 1:nSets
                set = info.sets(s);
                dimensions = set.ensDims;
                obj.ensembleDimensions{s} = dimensions;

                % If there are no members, we are finished with the set.
                % Otherwise, preallocate dimensional metadata
                if nMembers==0
                    continue;
                end
                nDims = numel(dimensions);
                obj.ensemble{s} = cell(1, nDims);

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
                    obj.ensemble{s}{k} = metadata;
                end
            end
        end
    end
end