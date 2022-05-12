classdef ensembleMetadata

    properties
        label_ = "";                    % A label for the metadata

        nVariables = 0;                 % The number of variables in the state vector ensemble
        variables_ = strings(0,1);      % The names of variables in the state vector ensemble
        lengths = NaN(0,1);             % The number of state vector elements for each variable

        stateDimensions = cell(0,1);    % The names of the dimensions with state elements for each variable
        stateSize = cell(0,1);          % The sizes of the dimensions with state elements for each variable
        state = struct();               % The state metadata for each variable
    end

    methods
        function[obj] = ensembleMetadata(sv)

            % Check the input is a scalar state vector
            header = "DASH:ensembleMetadata";
            dash.assert.scalarType(sv, "stateVector", 'sv', header);

            % Build and validate the gridfile objects
            [grids, failed, cause] = sv.prepareGrids;
            if failed
                gridfileFailedError;
            end

            % Copy the label from the state vector design
            obj.label_ = sv.label;

            % Get the variables and their lengths
            obj.variables_ = sv.variables;
            nVariables = numel(obj.variables_);
            obj.nVariables = nVariables;
            obj.lengths = sv.length(-1);

            % Initialize state dimension metadata
            obj.stateDimensions = cell(nVariables, 1);
            obj.stateSize = cell(nVariables, 1);
            obj.state = struct;

            % Get the dimensions with state elements for each variable
            for v = 1:nVariables
                svv = sv.variables_(v);
                dimensions = find(svv.isState | svv.hasSequence);
                obj.stateDimensions{v} = svv.dims(dimensions);
                obj.stateSize{v} = svv.stateSize(dimensions);

                % Get the gridfile metadata for the variable
                g = grids.whichGrid(v);
                gridmeta = grids.gridfiles(g).metadata;

                % Get metadata along each dimension with state vector elements
                stateMetadata = struct;
                for k = 1:numel(dimensions)
                    d = dimensions(k);
                    dim = svv.dims(d);

                    % State dimensions
                    if svv.isState(d)
                        metadata = gridmeta.(dim)(svv.indices{d},:);
                        if svv.meanType(d)~=0
                            metadata = permute(metadata, [3 2 1]);
                        end

                    % Sequences
                    else
                        metadata = svv.sequenceMetadata{d};
                    end

                    % Record the metadata for each dimension and variable
                    stateMetadata.(dim) = metadata;
                end
                variable = obj.variables_(v);
                obj.state.(variable) = stateMetadata;
            end

        end
    end
end







