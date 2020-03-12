function[addConstant] = getMeanAdjustment( Xt, Xs, nanflag )
%% Gets the additive constant needed to adjust the mean of a source dataset
% to match the mean of a target dataset.
%
% [addConstant] = getMeanAdjustment( Xt, Xs )
% Determines the additive constants needed to adjust the means of the rows
% of Xs to match the means of the rows of Xt.
%
% [addConstant] = getMeanAdjustment( Xt, Xs, nanflag )
% Specifies how to treat NaN values in the datasets.
%
% ----- Inputs -----
%
% Xt: The target ("true") dataset. Each row is treated independently. (nVar x nTime1)
%
% Xs: The source dataset. Typically the model prior. Each row is treated
%     independently. (nVar x nTime2)
%
% nanflag: A string specifying how to treat NaNs in the datsets. Default
%      behavior is to include NaN in means.
%      'includenan': Includes NaN values in means.
%      'omitnan': Removes NaN values before computing means.
%
% ----- Outputs -----
%
% addConstant: The additive constants needed to adjust the means of the rows
% of Xs to match the means of the rows of Xt.

% ----- Written By -----
% Jonathan King, University of Arizona, 2019

% Set default
if ~exist('nanflag','var')
    nanflag = 'includenan';
end

% Error check
if ~ismatrix(Xt) || ~isnumeric(Xt)
    error('Xt must be a numeric matrix.');
elseif ~ismatrix(Xs) || ~isnumeric(Xs)
    error('Xs must be a numeric matrix.');
elseif size(Xt,1) ~= size(Xs,1)
    error('The number of rows in Xs must match the number of rows of Xt.');
elseif ~ismember( nanflag, ["omitnan","includenan"] )
    error('Unrecognized nanflag.');
end

% Get the mean of each row
meanT = mean(Xt, 2, nanflag);
meanS = mean(Xs, 2, nanflag);

% Get the additive constants
addConstant = meanT - meanS;

end

