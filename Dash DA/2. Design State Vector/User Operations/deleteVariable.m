function[design] = deleteVariable( design, var )

% Get the variable index
v = checkDesignVar( design, var );

% Delete
design.var(v) = [];
design.varName(v) = [];

% Delete coupler indices
field = {'isCoupled','coupleState','coupleSeq','coupleMean'};
for f = 1:numel(field)
    design.(field{f})(v,:) = [];
    design.(field{f})(:,v) = [];
end

end