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
    obj.Rtype = NaN;
    if isempty(obj.Y) && isempty(obj.Ye)
        obj.nSite = 0;
    end
    if isempty(obj.Y) && isempty(obj.whichPrior)
        obj.nTime = 0;
    end

    % Collect output
    outputs = {obj};
    type = 'delete';

% Set uncertainties. Get defaults
else
    if ~exist('whichR','var') || isempty(whichVar)
        whichR = [];
    end

    % Don't allow empty R
    if isempty(R)
        emptyUncertaintiesError;
    end

    % Get sizes and detect variance vs covariance
    [nRows, nCols, nPages] = size(R, 1:3);
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

    % Note whether allowed to set nTime
    timeIsSet = true;
    if isempty(obj.Y) && isempty(obj.whichPrior)
        timeIsSet = false;
    end

    % Error check and process whichR
    obj = obj.processWhich(whichR, 'whichR', nR, name, timeIsSet, false, header);

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

    % Save, note type, build output
    obj.R = R;
    obj.Rtype = double(iscovariance);
    outputs = {obj};
    type = 'set';
end

end
