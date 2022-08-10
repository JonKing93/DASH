function[rst] = functionRST(title, examplesFile)
%% build.functionRST  Formats the reST markup for a function
% ----------
%   rst = build.functionRST(title)
%   Given the full dot-indexing title of a function, builds the reST markup
%   for the function's help documentation.
% ----------
%   Inputs:
%       title (string scalar): The full dot-indexing title of a functino
%       examplesFile (string scalar): The absolute path to the markdown
%           file holding the function examples.
%
%   Outputs:
%       rst (char vector): The reST markup for the function

% Default
try
    if ~exist('examplesFile','var') || isempty(examplesFile)
        examplesFile = [];
    end
    
    % Get the initial help text
    [h1, syntax, details] = get.help(title);
    details = get.aboveLink(title, details);
    
    % Parse the syntax section and test for inputs / outputs
    [signatures, descriptions] = parse.syntax(title, syntax);
    [hasInputs, hasOutputs] = parse.signatures(signatures);
    
    % Get the examples, inputs, and outputs. Optionally get prints and saves
    examples = get.examples(examplesFile);
    inputs = get.block('Inputs', details, hasInputs);
    outputs = get.block('Outputs', details, hasOutputs);
    prints = get.block('Prints', details, false);
    saves = get.block('Saves', details, false);
    
    % Parse the examples, input, and output blocks. Optionally parse for
    % prints and saves blocks
    [exampleLabels, exampleDetails] = parse.examples(examples);
    [inputNames, inputTypes, inputDetails] = parse.argBlock(inputs, 'the "Inputs" block');
    [outputNames, outputTypes, outputDetails] = parse.argBlock(outputs, 'the "Outputs" block');
    printsDescription = parse.miscBlock(prints, 'Prints');
    savesDescription = parse.miscBlock(saves, 'Saves');
    
    % Build the links to the syntax usage details and input/output parameters
    nSyntax = numel(signatures);
    syntaxLinks = link.syntax(title, nSyntax);
    inputLinks = link.args(title, 'inputs', inputNames);
    outputLinks = link.args(title, 'outputs', outputNames);
    
    % Add arg links to the signatures in the description section
    linkedSignatures = link.signatureArgs(signatures, inputNames, inputLinks, ...
                                                      outputNames, outputLinks);
    
    % Build accordion handles for collapsible sections
    exampleHandles = link.handles('examples', numel(exampleLabels));
    inputHandles = link.handles('inputs', numel(inputNames));
    outputHandles = link.handles('outputs', numel(outputNames));
    
    % Build the RST sections
    rst.title = format.title(title, h1);
    rst.syntax = format.syntax(signatures, syntaxLinks);
    rst.description = format.description(linkedSignatures, descriptions, syntaxLinks);
    rst.examples = format.examples(exampleLabels, exampleDetails, exampleHandles);
    rst.inputs = format.args('Input Arguments', inputNames, inputTypes, inputDetails, inputLinks, inputHandles);
    rst.outputs = format.args('Output Arguments', outputNames, outputTypes, outputDetails, outputLinks, outputHandles);
    rst.prints = format.misc('Prints', printsDescription);
    rst.saves = format.misc('Saves', savesDescription);
    
    % Join into the final RST
    rst = strcat(rst.title, rst.syntax, rst.description, rst.examples, rst.inputs, rst.outputs, rst.prints, rst.saves);
    
    % Trim the final transition line
    rst = char(rst);
    k = strfind(rst, '----');
    k = k(end);
    rst(k:end) = [];

% Informative error
catch cause
    if strcmp(cause.identifier, 'rst:parser')
        editLink = sprintf('<a href="matlab:edit %s">%s</a>', title, title);
        ME = MException('rst:parser', 'Could not build the reST for %s', editLink);
        ME = addCause(ME, cause);
        throw(ME);
    else
        rethrow(cause);
    end
end

end