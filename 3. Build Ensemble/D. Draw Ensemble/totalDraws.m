function[nDraws] = totalDraws(var)
%% Gets the total number of possible draws by taking the product of the
% number of ensemble indices.
%
% (At this point, ensemble indices should be restricted to matching
% metadata, etc. So each remaining ensemble index is a valid draw.)

% Initialize the number of draws
nDraws = 1;

% For each dimension
for d = 1:numel(var.dimID)
    
    % If an ensemble dimension
    if ~var.isState(d)
        
        % Mutliply by the number of ensemble indices
        nDraws = nDraws .* numel( var.indices{d} );
    end
end

end