function[toggle] = getUncouplerSwitches( state, ens, seq, mean )
%% Determines which indices to uncouple based on the uncoupler string flags.
%
% toggle = getUncouplerSwitches( state, ens, seq, mean )
    
% If ensemble is toggled, uncouple seq and mean as well
if ens   
    ens = true;
    seq = true;
    mean = true;
end
    
% If no toggles are activated, uncouple everything
if ~state && ~ens && ~seq && ~mean
    state = true;
    ens = true;
    seq = true;
    mean = true;
end

toggle = [state, ens, seq, mean];

end


