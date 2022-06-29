%% PSM.template  This file provides a template for developing new PSM classes

% This first line indicates that we a creating a new PSM class that
% conforms to the PSM interface.
%
% You should make a copy of this template, and then change "psmName" in the
% next line to whatever name you want to use for the PSM. Then, change the
% name of the copied file to <your name>.m
classdef psmName < PSM.Interface

    %% These next lines help describe the codebase for the PSM.
    properties (Constant)

        % This first property indicates whether the PSM is able to estimate
        % R error variance uncertainties. If the PSM *is* able to estimate
        % uncertainties, you should change its value from false to true.
        estimatesR = false;

        % The next property is a short description of the PSM. It's
        % optional, so you can leave this line alone if you prefer. But
        % filling it in can help other people understand your PSM
        description = "";

        % These next properties are optional. They help describe the
        % location of the PSM codebase on Github for the "PSM.download"
        % command. If you don't need the PSM.download command, you can just leave
        % these lines alone. Otherwise, fill in the values as appropriate.
        repository = "";        % The name of the Github repository with the code
        commit = "";            % The commit hash of the supported version of the PSM
        commitComment = "";     % Any extra details you want to include about the supported commit
    end

    %% In this next block, we'll include any parameters required to run the
    % forward model. These parameters are typically values that 
    %   1. Used as inputs to the forward model code, but 
    %   2. Are not in the state vector ensemble.
    %
    % Delete the two example parameters here and fill in the properties
    % block with whatever parameters are needed for your PSM
    properties
        exampleParameter1;
        exampleParameter2;
    end

    % Leave this next line alone
    methods

        %% In the following section, we'll write the function that creates a
        % new object for our new forward model. The name of the function
        % should match the name you used for the PSM in the "classdef" line
        %
        % The inputs to this function should be the model parameters we
        % listed in the previous properties block.
        function[obj] = psmName( exampleParameter1, exampleParameter2 )

            % First, do any error checking of the input parameters.
            %
            % Note that you don't *have* to strictly error check the
            % parameters, because the PSM.estimate command implements its
            % own error handling when the PSM. That said, more error
            % checking will usually make it easier for other people to use 
            % your PSM.
            % 
            % The following two lines are just an example. You should
            % delete them for your PSM and replace them with whatever error
            % checking you decide to do (if any)
            assert(exampleParameter1>0, 'Parameter 1 is not valid');
            assert(isstring(exampleParameter2), 'Parameter 2 is not valid');

            % Then, record the parameters for the object. Do this by
            % assigning  obj.<parameter name>  equal to the appropriate
            % input.
            %
            % The following two lines are just an example. You should
            % delete them for your PSM and replace them with whatever
            % parameters you use for your PSM
            obj.exampleParameter1 = exampleParameter1;
            obj.exampleParameter2 = exampleParameter2;
        end

        
        %% This next section provides the "rows" command
        %
        % The rows command is part of the PSM interface, and allows users
        % to indicate the state vector rows that should be used to run the
        % forward model. The rows command can also be used to return or
        % delete the current state vector rows for the PSM.
        %
        % Nearly all of this command is implemented by the "parseRows"
        % command, which is built-in to the PSM interface. The only thing
        % you need to do is to indicate the number of state vector rows
        % that are required to run the PSM. More details are provided below

        % This next line indicates that this is the beginning of the "rows"
        % command. Leave this line alone and do not alter it.
        function[output] = rows(obj, rows)

            % These next lines help pass inputs to the "parseRows" command.
            % You should also leave them unaltered.
            inputs = {};
            if exist('rows', 'var')
                
                % This next line is where you may need to alter the
                % template. The number after the word rows indicates the
                % number of state vector rows that are required to run the
                % forward model.
                %
                % This example arbitrarily lists the number 5 after the word
                % rows. So this indicates that the example forward model
                % requires information from 5 state vector rows to run the
                % forward model.
                % 
                % You should change the number 5 to however many state 
                % vector rows are required to run your forward model
                inputs = {rows, 5};

            % The remaining lines pass the inputs to the "parseRows"
            % function. You should leave these lines unaltered.
            end
            output = obj.parseRows(inputs{:});
        end

        %% This final section implements the "estimate" command
        %
        % The estimate command is part of the PSM interface, and is the
        % part of the code that actually runs a forward model on inputs
        % extracted from a state vector ensemble. This section is known as
        % a wrapper. Essentially, it calls some external code that implements
        % a forward model, and returns the results of that forward model in
        % a consistent format.

        % This first line begins the function. The uncommented line below
        % shows the syntax for a PSM does not have the ability to estimate
        % R error variance uncertainties.
        %
        % If your PSM *does* have the ability to estimate R values, then
        % you should comment out the next line, and uncomment the line
        % below it instead
        function[Ye] = estimate(obj, X)          % Use this line if you don't estimate R
%         function[Y, R] = estimate(obj, X)     % Use this line if you *do* estimate R

            % The state vector inputs will always be provided as an array
            % with size [nRows x nMembers x nEvolving]. Each row is a
            % variable extracted from the rows of a state vector ensemble.
            %
            % The order of the variables will match the order that rows are
            % provided to the "rows" command. If you need to split apart
            % the state vector variables into multiple climate variable,
            % you should do so here.
            %
            % In this example, we'll pretend the first 3 rows are a
            % temperature variable, and the last 2 rows are a precipitation
            % variable. We'll split them apart here. But note that this is
            % just an example. You should delete these lines and replace
            % them with whatever is appropriate for your PSM
            %
            % Note that the input state vector rows will be an array with
            % up to 3 dimensions. So you should reference both the 2nd and
            % 3rd dimensions of X when splitting out variables.
            T = X(1:3,:,:);
            P = X(4:5,:,:);

            % Next run the forward model. This is typically some external
            % function that takes 
            %   1. The state vector inputs, and
            %   2. The model parameters as inputs.
            %
            % You can obtain the saved model parameters by using
            %   obj.<parameter name>
            % (See the line below for an example
            Ye = someFunction(T, P, obj.exampleParameter1, obj.exampleParameter2);

            % The Ye and R outputs must be arrays of size:
            %   [1 x nMembers x nEvolving]
            %
            % If they are not this size, the PSM.estimate command will
            % reject the outputs. If you need to do any post-processing to
            % ensure that the Ye and R outputs are the correct size, you
            % can do so here
            ...         % Shape Ye to correct size
            ...         % Shape R to correct size

            % The remaining lines are the end of the PSM. Leave them
            % unaltered
        end
    end
end