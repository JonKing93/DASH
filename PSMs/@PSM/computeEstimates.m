function[Ye, R] = computeEstimates(X, F)
%% This is the low-level function that actually estimates proxy values. 
% Does not apply error checking

% Sizes
nSite = numel(F);
[~, nEns, nPrior] = size(X);

% Preallocate
Ye = NaN(nSite, nEns, nPrior);
if nargout>1
    R = NaN(nSite, nEns, nPrior);
end

% Get the estimates for each PSM.
for s = 1:nSite
    psm = F{s};
    
    % Propagate rows over ensemble members and priors
    siz = size(psm.rows, 1:3);
    if siz(2)==1
        psm.rows = repmat(psm.rows, [1 nEns, 1]);
    end
    if siz(3)==1
        psm.rows = repmat(psm.rows, [1 1 nPrior]);
    end
    
    % Extract the data required to run the PSM
    [~, c, p] = ind2sub(siz, 1:prod(siz));
    index = sub2ind([nState, nEns, nPrior], psm.rows(:), c, p);
    Xpsm = reshape( X(index), siz );
    
    % Run the PSM for each prior
    for p = 1:nPrior
        Xrun = Xpsm(:,:,p);
        
        % Run the PSM with R estimation
        ranPSM = false;
        if nargout>1 && psm.estimatesR
            Rfailed = false;
            try
                [Yrun, Rrun] = psm.runPSM(Xrun);
                ranPSM = true;           
            catch
                Rfailed = true;
            end            
            if ~isnumeric(Rrun) || ~isrow(Rrun) || numel(Rrun)~=nEns
                Rfailed = true;
            end
            
            % Notify user and reset R if failed
            if Rfailed
               warning('Failed to estimate R values for %s for prior %.f', psm.messageName(s), p);
               Rrun = NaN(1, nEns);
            end
        end
        
        % Run the PSM without R estimation
        if ~ranPSM
            Yrun = psm.runPSM(Xrun);
        end
        
        % Error check the Y output
        name = sprintf('Y values for %s for prior %.f', psm.messageName(s), p);
        dash.assertVectorTypeN(Yrun, 'numeric', nEns, name);
        if ~isrow(Yrun)
            error('%s must be a row vector', name);
        end  
        
        % Record values
        Ye(s,:,p) = Yrun;
        if nargout>1 && psm.estimatesR
            R(s,:,p) = Rrun;
        end
    end
end

end