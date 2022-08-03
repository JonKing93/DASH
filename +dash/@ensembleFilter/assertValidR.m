function[] = assertValidR(obj, header)
%% dash.ensembleFilter.assertValidR  Check that observations have an R variance or covariance in required time steps
% ----------
%   obj.assertValidR(header)
%   Throws an error if any observation lacks an R variance or covariance in
%   a required time step.
% ----------
%   Inputs:
%       header (string scalar): Header for thrown error IDs
% 
% <a href="matlab:dash.doc('dash.ensembleFilter.assertValidR')">Documentation Page</a>

% Only check values if the filter has both observations and uncertainties
if isempty(obj.Y) || isempty(obj.R)
    return
end

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensembleFilter:assertValidR";
end

% Get whichR, fill empty (static) values with ones
if isempty(obj.whichR)
    obj.whichR = ones(obj.nTime, 1);
end

% Get the time steps associate with each set of R values
for c = 1:obj.nR
    times = find(obj.whichR == c);

    % Check for missing R variances...
    if obj.Rtype==0
        obs = ~isnan(obj.Y(:,times));
        siteHasObs = any(obs, 2);
        noUncertainty = isnan(obj.R(:,c));
        missingPairs = siteHasObs & noUncertainty;

        % Missing error variances
        if any(missingPairs)
            site = find(missingPairs,1);
            id = sprintf('%s:missingRVariance', header);

            % Single or multiple sets of variances
            if obj.nR==1
                ME = MException(id, ['The R variance for site %.f is NaN, but site %.f has ',...
                    'non-NaN values in some time steps.'], site, site);
            else
                ME = MException(id, ['The R variance for site %.f in time step %.f is NaN, ',...
                    'but the observation for site %.f is not NaN in this time step.\n',...
                    'Site: %.f\nSet of R variances: %.f'], site, times(1), site,...
                    site, c);
            end
            throwAsCaller(ME);
        end

    % Check for missing covariance
    else
        [site1, site2] = find(isnan(obj.R(:,:,c)));
        for k = 1:numel(times)
            t = times(k);
            nan1 = isnan(obj.Y(site1, t));
            nan2 = isnan(obj.Y(site2, t));
            missingPairs = ~nan1 & ~nan2;

            % Missing covariance
            if any(missingPairs)
                pair = find(missingPairs, 1);
                id = sprintf('%s:missingRCovariance', header);

                % Single vs multiple covariances
                if obj.nR==1
                    ME = MException(id, ['The R covariance between sites %.f and %.f is NaN, ',...
                        'but there are time steps when neither site is NaN.'],...
                        site1(pair), site2(pair));
                else
                    ME = MException(id, ['The R covariance between sites %.f and %.f is NaN in time ',...
                        'step %.f, but neither observation site is NaN in that time step.',...
                        'Sites: %.f, %.f\nSet of R covariances: %.f'], sites1(pair), sites2(pair), ...
                        times(1), sites1(pair), sites2(pair), c);
                end
                throwAsCaller(ME);
            end
        end
    end
end

end