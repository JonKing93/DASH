function[unbias] = unbias(N)
%% dash.math.unbias  Returns the coefficient of unbiased estimation
% ----------
%   unbias = dash.math.unbias(N)
%   Returns the coefficient of unbiased estimation for a sample size of N.
%   The coefficient is calculated via:   unbias = 1 / (N - 1)
% ----------
%   Inputs:
%       N (scalar positive integer): The sample size
%
%   Outputs:
%       unbias (numeric scalar): The coefficient of unbiased estimation
%
% <a href="matlab:dash.doc('dash.math.unbias')">Documentation Page</a>

unbias = 1 / (N - 1);

end