function[whichArg] = parseWhich(kf, whichArg, name, nIndex, indexName)
%% Parses which* inputs for evolving settings
%
% whichArg = kf.parseWhich(whichArg, name, nIndex, indexName)
%
% ----- Inputs -----
%
% whichArg: The which* input
%
% name: The name of the which* input in the calling function
%
% nIndex: The indices that can be referenced by whichArg
%
% indexName: The name of the quantity being indexed
%
% ----- Outputs -----
%
% whichArg: The which* input adjusted for any default settings

% If there is a single setting, cannot use whichArg
empty = isempty(whichArg);
if nIndex==1 && ~empty
    error(['You have provided a single %s, so you cannot use the "%s" input ',...
        'to specify time steps.'], indexName, name);
    
% Otherwise, default or require whichArg
elseif nIndex>1
    if empty && (nIndex==kf.nTime || kf.nTime==0)
        kf.nTime = nIndex;
        whichArg = 1:kf.nTime;
    elseif empty
        error(['The number of %ss (%.f) does not match the number of time steps ',...
            '(%.f), so you must use the "%s" input to specify which ',...
            '%s to use in each time step.'], indexName, nIndex, kf.nTime, name, indexName);
    end
    
    % Error check
    dash.assertVectorTypeN(whichArg, 'numeric', kf.nTime, name);
    dash.checkIndices(whichArg, name, nIndex, strcat('the number of %ss', indexName));
    whichArg = whichArg(:);
end
    
end