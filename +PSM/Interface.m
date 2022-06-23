classdef (Abstract) Interface

    properties (SetAccess = private)
        label_;
        rows;
    end

    properties (Abstract, Hidden, SetAccess = protected)
        estimatesR;
        description;
        repository;
        commit;
        repoComment;
    end

    methods (Abstract)
        [Y, R] = run(obj, X);
    end

    methods
        function[varargout] = label(obj, label)
            %% PSM.Interface.label  Return or set the label of a PSM object
            % ----------
            %   label = obj.label
            %   Returns the label of the current PSM object.
            %
            %   obj = obj.label(label)
            %   Applies a new label to the PSM object
            % ----------
            %   Inputs:
            %       label (string scalar): A new label for the PSM
            %
            %   Outputs:
            %       label (string scalar): The current label of the object
            %       obj (scalar PSM.Interface object): The object with an updated label.
            %
            % <a href="matlab:dash.doc('PSM.Interface.label')">Documentation Page</a>
            
            % Setup
            header = "DASH:PSM:label";
            dash.assert.scalarObj(obj, header);
            
            % Return current label
            if ~exist('label','var')
                varargout = {obj.label_};
            
            % Apply new label
            else
                obj.label_ = dash.assert.strflag(label, 'label', header);
                varargout = {obj};
            end
        end    
        
        
        
        
        
        name = name(obj);
        obj = useRows(obj, rows);
    end

    % Constructor
    methods
        function[obj] = Interface(header, label)
            %% PSM.Interface  Initialize and label a new PSM object
            % ----------
            %   obj = PSM.Interface(header)
            %   Initializes a new PSM object without a label.
            %
            %   obj = PSM.Interface(header, label)
            %   Applies a label to the new PSM object.
            % ----------
            %   Inputs:
            %       header (string scalar): Header for thrown error IDs
            %       label (string scalar): A label for the new PSM object
            %
            %   Outputs:
            %       obj (scalar PSM.Interface object): The new PSM object
            %
            % <a href="matlab:dash.doc('PSM.Interface')">Documentation Page</a>

            % Default
            if ~exist('header','var')
                header = "DASH:PSM";
            end

            % Optionally label
            if exist('label', 'var')
                obj.label_ = dash.assert.strflag(label, 'label', header);
            end
        end
    end

end
