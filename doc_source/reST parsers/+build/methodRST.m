function[rst] = methodRST(classTitle, methodName, examplesFile)
%% build.methodRST  Builds and writes the reST markup for a clas method
% ----------
%   document.methodRST(classTitle, name, examplesFile)
% ----------
%   Inputs:
%       classTitle (string scalar): The full dot-indexing title of the
%           class that contains the method
%       methodName (string scalar): The name of the method
%       examplesFile (string scalar): The absolute path to the file holding
%           the examples markdown
%
%   Outputs:
%       rst (char vector): The reST markup for a class method

% Get the initial help text
try
    fullTitle = strcat(classTitle, ".", methodName);
    [h1, syntax, details] = get.help(fullTitle);
    details = get.aboveLink(fullTitle, details);

    % Initially search a static method title
    syntaxTitle = fullTitle;
    type = 'static';

    % If the absolute title is not in the syntax, search for object tags
    if ~contains(syntax, fullTitle)
        objectTitles = [strcat("obj.", methodName); strcat(methodName, "(obj")];
        objectIndices = [strfind(syntax, objectTitles(1)), strfind(syntax, objectTitles(2))];

        % If there are tags, require that they are bracketed by strong tags
        if ~isempty(objectIndices)
            strongTitles = [strcat("<strong>", objectTitles(1), "</strong>"); ...
                            strcat("<strong>", methodName, "</strong>(obj")];
            strongIndices = [strfind(syntax, strongTitles(1)), strfind(syntax, strongTitles(2))];
            if numel(strongIndices) < numel(objectIndices)
                error('rst:parser', 'Not all syntax signatures have <strong> tags');
            end

            % Use object signatures
            type = 'object';
            syntaxTitle = strongTitles;

        % If there are no tags, search for a constructor signature
        else
            constructorTitle = classTitle;
            strongTitles = strcat("<strong>", constructorTitle, "</strong>");

            % Use the constructor signature or throw an error if missing
            if ~contains(syntax, strongTitles)
                error('rst:parser', 'Cannot locate syntax signature');
            end
            syntaxTitle = strongTitles;
            type = 'constructor';
        end
    end
    
    % Parse the syntax section, remove strong tags. Test for inputs / outputs
    [signatures, descriptions] = parse.syntax(syntaxTitle, syntax);
    if strcmp(type, 'object')
        signatures = replace(signatures, strongTitles, objectTitles);
    elseif strcmp(type, 'constructor')
        signatures = replace(signatures, strongTitles, constructorTitle);
    end
    [hasInputs, hasOutputs] = parse.signatures(signatures);
    
    % Get the examples, inputs, and outputs
    examples = get.examples(examplesFile);
    inputs = get.block('Inputs', details, hasInputs);
    outputs = get.block('Outputs', details, hasOutputs);
    prints = get.block('Prints', details, false);
    saves = get.block('Saves', details, false);
    downloads = get.block('Downloads', details, false);
    
    % Parse the examples, input, and output blocks
    [exampleLabels, exampleDetails] = parse.examples(examples);
    [inputNames, inputTypes, inputDetails] = parse.argBlock(inputs, 'the "Inputs" block');
    [outputNames, outputTypes, outputDetails] = parse.argBlock(outputs, 'the "Outputs" block');
    printsDescription = parse.miscBlock(prints, 'Prints');
    savesDescription = parse.miscBlock(saves, 'Saves');
    downloadsDescription = parse.miscBlock(downloads, 'Downloads');
    
    % Build the links to the syntax usage details and input/output parameters
    nSyntax = numel(signatures);
    syntaxLinks = link.syntax(fullTitle, nSyntax);
    inputLinks = link.args(fullTitle, 'inputs', inputNames);
    outputLinks = link.args(fullTitle, 'outputs', outputNames);
    
    % Add arg links to the signatures in the description section
    linkedSignatures = link.signatureArgs(signatures, inputNames, inputLinks, ...
                                                      outputNames, outputLinks);
    
    % Build accordion handles for collapsible sections
    exampleHandles = link.handles('examples', numel(exampleLabels));
    inputHandles = link.handles('inputs', numel(inputNames));
    outputHandles = link.handles('outputs', numel(outputNames));
    
    % Build the RST sections
    rst.title = format.title(fullTitle, h1);
    rst.syntax = format.syntax(signatures, syntaxLinks);
    rst.description = format.description(linkedSignatures, descriptions, syntaxLinks);
    rst.examples = format.examples(exampleLabels, exampleDetails, exampleHandles);
    rst.inputs = format.args('Input Arguments', inputNames, inputTypes, inputDetails, inputLinks, inputHandles);
    rst.outputs = format.args('Output Arguments', outputNames, outputTypes, outputDetails, outputLinks, outputHandles);
    rst.prints = format.misc('Prints', printsDescription);
    rst.saves = format.misc('Saves', savesDescription);
    rst.downloads = format.misc('Downloads', downloadsDescription);

    % Join into the final RST
    rst = strcat(rst.title, rst.syntax, rst.description, rst.examples, ...
        rst.inputs, rst.outputs, rst.prints, rst.saves, rst.downloads);
    
    % Trim the final transition line
    rst = char(rst);
    k = strfind(rst, '----');
    k = k(end);
    rst(k:end) = [];

% Informative error
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        editLink = sprintf('<a href="matlab:edit %s">%s</a>', fullTitle, fullTitle);
        ME = MException('rst:parser', 'Could not build the reST for %s', editLink);
        ME = addCause(ME, cause);
        throw(ME);
    else
        rethrow(cause);
    end
end

end