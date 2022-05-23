function[] = assertEditableCovariance(kf, type)
%% Checks that a prior and observations have been specified before
% setting covariance options.
%
% kf.assertEditableCovariance(type)
%
% ----- Inputs -----
%
% type: A string listing the type of covariance modification being made.
%    Use for error messages.

% Require a prior
if isempty(kf.X)
    error(['You must specify a prior (using the "prior" command) before ',...
        'setting %s.'], type);
    
% Require observations
elseif isempty(kf.Y)
    error(['You must specify the observations/proxies (using the ',...
        '"observations" command) before setting %s.'], type);
end

end