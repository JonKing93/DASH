function[design] = markCoupled( design, xv, yv, syncState, syncSeq, syncMean )

% Get the field names
field = {'isCoupled','coupleState','coupleSeq','coupleMean'};

% Get whether the indices are coupled
tf = [true, syncState, syncSeq, syncMean];

% For each field that is synced
for f = 1:numel(field)
    if tf(f)
        
        % Get the coupled variables
        coupled = [find( design.(field{f})(xv,:) ), xv];

        % Add the new variable
        design.(field{f})(coupled, yv) = true;
        design.(field{f})(yv, coupled) = true;
    end
end

end
