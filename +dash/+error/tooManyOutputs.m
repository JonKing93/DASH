function[] = tooManyOutputs
%% dash.error.tooManyOutputs  Throws a MATLAB-style error when there are too many output arguments
% ----------
%   dash.error.tooManyOutputs
%   Throws the error as if it originates from the calling function.
% ----------
%
% <a href="matlab:dash.doc('dash.error.tooManyOutputs')">Documentation Page</a>

ME = MException('MATLAB:TooManyOutputs', 'Too many output arguments.');
throwAsCaller(ME);

end