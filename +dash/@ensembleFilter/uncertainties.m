function[outputs, type] = uncertainties(obj, header, R, whichR)

% Default
if ~exist('header','var') || isempty(header)
    header = "DASH:ensembleFilter:uncertainties";
end

% Return uncertainties
if ~exist('R','var')
    outputs = {obj.R, obj.whichR};
    type = 'return';

% Delete current matrix. Don't allow second input
elseif dash.is.strflag(R) && strcmpi(R, 'delete')
    if exist('whichR','var')
        dash.error.tooManyInputs;
    end

    % Delete and reset sizes
    obj.R = [];
    obj.nR = 0;
    obj.whichR = [];
    obj.Rtype = [];
    if isempty(obj.Y) && isempty(obj.Ye)
        obj.nSite = 0;
    end
    if isempty(obj.Y) && isempty(obj.whichPrior)
        obj.nTime = 0;
    end

    % Collect output
    outputs = {obj};
    type = 'delete';

% Set uncertainties. Get defaults and sizes
else
    if ~exist('whichR','var') || isempty(whichVar)
        whichR = [];
    end
    [nRows, nCols, nPages] = size(R, 1:3);


    %% Initial error checking

    % Detect variance vs covariance
    if ~ismatrix(R)
        iscovariance = true;
    elseif nRows ~= nCols
        iscovariance = false;
    elseif obj.nTime>0 && obj.nTime~=nCols
        iscovariance = true;
    else
        ambiguousUncertaintyError;
    end

    % Parse and set the number of uncertainty sets
    if iscovariance
        nR = nPages;
    else
        nR = nCols;
    end
    obj.nR = nR;

    % Optionally set the number of sites
    if isempty(obj.Y) && isempty(obj.Ye)
        obj.nSite = nRows;
    end

    % Error check size and type. Require well defined values
    if iscovariance
        name = 'R covariances';
        siz = [obj.nSite, obj.nSite, NaN];
        dash.assert.blockTypeSize(R, 'numeric', siz, name, header);
    else
        name = 'R variances';
        siz = [obj.nSite, NaN];
        dash.assert.matrixTypeSize(R, 'numeric', siz, name, header);
    end
    dash.assert.defined(R, 2, name, header);


    %% Error check whichR

    % Note whether allowed to set nTime
    timeIsSet = true;
    if isempty(obj.Y) && isempty(obj.whichPrior)
        timeIsSet = false;
    end

    % Unspecified whichR. Take no actions for static R. If evolving,
    % set time when unset. If set, require one set of R values per time step
    if isempty(whichR)
        if nR > 1
            if ~timeIsSet
                obj.nTime = nR;
            end
            if nR ~= obj.nTime
                wrongSizeError;
            end
            whichR = (1:obj.nTime)';
        end

    % Parse user whichR. If time is set, require one element per time step.
    % If unset and evolving, set nTime to the number of whichR
    else
        nRequired = [];
        if timeIsSet
            nRequired = obj.nTime;
        elseif nR > 1
            obj.nTime = numel(whichR);
        end
        dash.assert.vectorTypeN(whichR, 'numeric', nRequired, 'whichR', header);
        linearMax = sprintf('the number of sets of %s', name);
        dash.assert.indices(whichR, nR, 'whichR', [], linearMax, header);
    end


    %% Additional error checking. Save values

    % Only allow positive variances
    if ~iscovariance
        isnegative = R <= 0;
        if any(isnegative)
            negativeVarianceError;
        end

    % Covariances sets must be symmetric matrices. Infill NaN with 1s to
    % allow matrix comparison
    else
        for c = 1:nR
            Rc = R(:,:,c);
            Rnan = isnan(Rc);
            Rc(Rnan) = 1;
            if ~issymmetric(Rnan) || ~issymmetric(Rc)
                notSymmetricError;
            end

            % Also require diagonals to be NaN or positive
            Rdiag = diag(Rc);
            isnegative = Rdiag <= 0;
            if any(isnegative)
                negativeDiagonalError;
            end
        end
    end

    % Save uncertainties. Note type. Only record whichR if evolving
    obj.R = R;
    obj.Rtype = double(iscovariance);
    if nR > 1
        obj.whichR = whichR(:);
    end

    % Collect output
    outputs = {obj};
    type = 'set';
end

end
