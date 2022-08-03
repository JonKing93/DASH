function[] = tooManyInputs
%% dash.error.tooManyInputs  Throws a MATLAB-style error when there are too many input arguments
% ----------
%   dash.error.tooManyInputs
%   Throws the error as if it originates from the calling function.
% ----------
%
% <a href="matlab:dash.doc('dash.error.tooManyInputs')">Documentation Page</a>

ME = MException('MATLAB:TooManyInputs', 'Too many input arguments.');
throwAsCaller(ME);

end