function[timesConstant, addConstant] = getRenormalization( Xt, Xs )
%% Gets the multiplicative and additive constants needed to adjust the mean
% and variance of a source dataset to match a target dataset.
%
% [timesConstant, addConstant] = getRenormalization( Xt, Xs )
% Determines the constants needed to adjust the means and standard
% deviations of the rows of Xs to match those of Xt.
%
% [timesConstant, addConstant] = getRenormalization( Xt, Xs, nanflag )
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
% timesConstant: The multiplicative constants needed to adjust the standard
% deviations of the rows of Xs to match the rows of Xt. 
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

% Get the means
meanS = mean(Xs, 2, nanflag);
meanT = mean(Xt, 2, nanflag);

% Get the standard deviations
stdS = std( Xs, 0, 2, nanflag );
stdT = std( Xs, 0, 2, nanflag );

% Get the renormalization
timesConstant = (stdT ./ stdS);
addConstant = meanT - (stdT .* meanS ./ stdS);

end