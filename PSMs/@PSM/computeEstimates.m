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

% Get the values needed to run each PSM for each prior
for s = 1:nSite
    Xpsm = X(F{s}.rows, :, :);
    for p = 1:nPrior
        Xrun = Xpsm(:,:,p);
        
        % Run the PSM with R estimation
        ranPSM = false;
        if nargout>1 && F{s}.estimatesR
            Rfailed = false;
            try
                [Yrun, Rrun] = F{s}.runPSM(Xrun);
                ranPSM = true;           
            catch
                Rfailed = true;
            end            
            if ~isnumeric(Rrun) || ~isrow(Rrun) || numel(Rrun)~=nEns
                Rfailed = true;
            end
            
            % Notify user and reset R if failed
            if Rfailed
               warning('Failed to estimate R values for %s for prior %.f', F{s}.messageName, p);
               Rrun = NaN(1, nEns);
            end
        end
        
        % Run the PSM without R estimation
        if ~ranPSM
            Yrun = F{s}.runPSM(Xrun);
        end
        
        % Error check the Y output
        name = sprintf('Y values for %s for prior %.f', F{s}.messageName(s), p);
        dash.assertVectorTypeN(Yrun, 'numeric', nEns, name);
        if ~isrow(Yrun)
            error('%s must be a row vector', name);
        end  
        
        % Record values
        Ye(s,:,p) = Yrun;
        if nargout>1 && F{s}.estimatesR
            R(s,:,p) = Rrun;
        end
    end
end

end