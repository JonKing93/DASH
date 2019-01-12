function[design] = addVariable( design, file, name )
% design = addVariable( design, file, name )

% File check, get default name
meta = metaGridfile(file);

 % Get the name if not specified
if ~exist('name','var')
    name = meta.var;
end

% Check that the variable is not a repeat
if ismember(name, design.varName)
    error('Cannot repeat variable names.');
end

% Initialize the varDesign
newVar = varDesign(file, name);           

% Add the variable
design.var = [design.var; newVar];
design.varName = [design.varName; {name}];

% Adds coupler indices
design.isCoupled(end+1,end+1) = false;
design.coupleState(end+1,end+1) = false;
design.coupleSeq(end+1,end+1) = false;
design.coupleMean(end+1,end+1) = false;

end