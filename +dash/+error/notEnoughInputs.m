function[] = notEnoughInputs
%% dash.error.notEnoughInputs  Throws a MATLAB-style error when there are not enough input arguments
% ----------
%   dash.error.notEnoughInputs
%   Throws the error as if it originates from the calling function.
% ----------
%
% <a href="matlab:dash.doc('dash.error.notEnoughInputs')">Documentation Page</a>

ME = MException('MATLAB:minrhs', 'Not enough input arguments');
throwAsCaller(ME);

end