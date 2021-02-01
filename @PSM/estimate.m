function[Ye, R] = estimate(X, F)
%% Estimates proxies values from a state vector ensemble
%
% Ye = PSM.estimate(X, psms)
% Estimates proxies values for a state vector ensemble given a
% set of PSMs.
%
% [Ye, R] = PSM.estimates(X, psms)
% Also estimates proxy uncertainties (R).
%
% ----- Inputs -----
%
% X: A state vector ensemble. A numeric array with the
%    following dimensions (State vector x ensemble members x priors)
%
% psms: A set of PSMs. Either a scalar PSM object or a cell
%    vector whose elements are PSM objects.
%
% ----- Outputs -----
%
% Ye: Proxy estimates. A numeric array with the dimensions
%    (Proxy sites x ensemble members x priors)
%
% R: Proxy uncertainty estimates. A numeric array with
%    dimensions (proxy sites x ensemble members x priors)

% Parse and error check the ensemble. Get size
if isa(X, 'ensemble')
    isens = true;
    assert(isscalar(X), 'ens must be a scalar ensemble object');
    [nState, nEns] = X.metadata.sizes;
    nPriors = 1;
    m = matfile(X.file);
else
    assert(isnumeric(X), 'X must be numeric');
    assert(ndims(X)<=3, 'X cannot have more than 3 dimensions');
    isens = false;
    [nState, nEns, nPriors] = size(X);
end

% Error check the ensemble, get sizes
dash.assertRealDefined(X, 'X');

% Parse the PSM vector
nSite = numel(F);
[F, wasCell] = dash.parseInputCell(F, nSite, 'F');
name = "F";

% Error check the individual PSMs
for s = 1:nSite
    if wasCell
        name = sprintf('Element %.f of F', s);
    end
    dash.assertScalarType(F{s}, name, 'PSM', 'PSM');

    % Check the rows of the PSM do not exceed the number of rows
    if max(F{s}.rows) > nState
        error('The ensemble has %.f rows, but %s uses rows that are larger (%.f)', ...
            nState, F{s}.messageName(s), max(F{s}.rows));
    end
end

% Preallocate
Ye = NaN(nSite, nEns, nPriors);
if nargout>1
    R = NaN(nSite, nEns, nPriors);
end

% Get the values needed to run each PSM
for s = 1:nSite
    if ~isens
        Xpsm = X(F{s}.rows,:,:);

    % If using an ensemble object, first attempt to read all rows at once
    else
        try
            rows = dash.equallySpacedIndices(F{s}.rows);
            Xpsm = m.X(rows,:);
            [~, keep] = ismember(F{s}.rows, rows);
            Xpsm = Xpsm(keep,:);

        % If unsuccessful, load values iteratively
        catch
            nRows = numel(F{s}.rows);
            Xpsm = NaN(nRows, nEns);
            for r = 1:nRows
                Xpsm(r,:) = m.X(F{s}.rows(r),:);
            end
        end
    end

    % Get the values for each prior and run the PSM
    for p = 1:nPriors
        Xrun = Xpsm(:,:,p);
        if nargout>1
            [Yrun, Rrun] = F{s}.runPSM(Xrun);
        else
            Yrun = F{s}.runPSM(Xrun);
        end

        % Error check the R output
        if nargout>1
            name = sprintf('R values for %s for prior %.f', F{s}.messageName(s), p);
            dash.assertVectorTypeN(Rrun, 'numeric', nEns, name);
            if ~isrow(Rrun)
                error('%s must be a row vector', name);
            end
        end

        % Error check the Y output
        name = sprintf('Y values for %s for prior %.f', F{s}.messageName(s), p);
        dash.assertVectorTypeN(Yrun, 'numeric', nEns, name);
        if ~isrow(Yrun)
            error('%s must be a row vector', name);
        end

        % Save
        Ye(s,:,p) = Yrun;
        if nargout>1
            R(s,:,p) = Rrun;
        end
    end
end
end