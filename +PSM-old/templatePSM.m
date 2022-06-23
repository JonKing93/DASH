%% This is a template for adding new PSMs to DASH

% This first line specifies the name of the new PSM. You should change the
% word "templatePSM" to whatever name you want to use for the PSM.
classdef templatePSM < PSM.Interface
    
    % The properties block holds any input parameters required to run the
    % PSM. Parameters include any PSM inputs that are **not** in a state
    % vector ensemble. They usually don't include climate variables
    % (like temperature or precipitation).
    properties
        psmParameter1;
        psmParameter2;
    end
    
    methods (Static) % Don't change this line
        
        % This block holds the static "run" function. It is essentially a
        % wrapper that calls the function used to run the PSM. The
        % inputs to "run" are usually the same as the inputs to the PSM
        % function.
        %
        % The "run" function must output proxy estimates Y as the first output.
        % It can optionally also output proxy uncertainty estimates R as a
        % second output.
        %
        % If you do not use the PSM to estimate R, then remove R from the
        % outputs list in the next line.
        function[Y, R] = run(X, psmParameter1, psmParameter2)
            
            % If you want to error check the psm inputs, do so here.
            %
            %
            
            % Next, run the PSM by calling the PSM function
            output = psmFunction(X, psmParameter1, psmParameter2);
            
            % If you need to process the PSM output, do so here
            Y = someFunction(output);
            R = someFunction(output);
        end
    end
    
    methods % Don't change this line
        
        % This next function is used to create the PSM for a specific proxy
        % site. It is known as a "constructor". The constructor function
        % should have the same name as this PSM class. Its first input
        % should be "rows" -- the state vector rows holding the climate
        % data required to run the PSM. Next, include any input parameters
        % required to run the PSM. These are the input parameters noted in
        % the "properties" block. Finally, the last input should be "name",
        % an optional name for the PSM. The function should have a single
        % output "obj" -- this is the new PSM object.
        function[obj] = templatePSM(rows, psmParameter1, psmParameter2, name)
        
            % (You don't need to change this block -- it provides an empty 
            % name for the PSM if the user does not provide one).
            if ~exist('name','var') || isempty(name)
                name = "";
            end
            
            % This next line specifies two things: 1. The name of the PSM,
            % and 2. Whether the PSM is used to estimate proxy 
            % uncertainties (R). If you use the PSM to estimate R, then
            % leave the second input as true. If you do not use the PSM to
            % estimate R, change the second input to false.
            obj@PSM.Interface(name, true);
            
            % If you would like to error check the state vector rows, you
            % can do so here.
            %
            %
            
            % (You don't need to change this line -- it sets the state
            % vector rows for the PSM)
            obj = obj.useRows(rows);
            
            % If you would like to error check the PSM parameters, you can
            % do so here.
            %
            %
            
            % This block saves the PSM parameters for the PSM. Each line
            % sets the property for a parameter (obj.parameterName) equal
            % to the input parameter.
            obj.psmParameter1 = psmParameter1;
            obj.psmParameter2 = psmParameter2;
        end
            
        % The final function "runPSM" passes state vector data to the PSM.
        % You do not need to change the inputs. The first "obj" is the PSM
        % object for a proxy site, and "X" is the state vector data. Note
        % that X is a matrix: each row is a climate variable, and each
        % column is an ensemble member.
        %
        % The "runPSM" function always has at least one output. This is Y,
        % the proxy estimates. Y must **always** be a row vector. The
        % function has an optional second output R, proxy uncertainty
        % estimates, just like the "run" function. Like Y, the R output
        % must **always** be a row vector.
        %
        % If you do not use the PSM to estimate R, then remove it from the
        % output list in the next line.
        function[Y, R] = runPSM(obj, X)
            
            % If you need to break apart the state vector data into
            % separate climate variables, do so here.
            %
            %
            
            % Use the "run" function to run the PSM. You can provide the
            % climate variables directly. You can provide any PSM
            % parameters by referencing the PSM object's properties.
            %
            % If your PSM does not estimate proxy uncertainty, you should
            % remove R from the outputs in the next line.
            [Y, R] = obj.run(X, obj.psmParameter1, obj.psmParameter2);
            
            % If you need to manipulate Y or R to ensure they are row
            % vectors, do so here.
            %
            %
        end
    end
    
end