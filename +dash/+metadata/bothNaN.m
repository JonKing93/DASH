function[tf] = bothNaN(A, B)
%% dash.metadata.bothNaN  True if two inputs are both scalar NaN
% ----------
%   tf = dash.metadata.bothNaN(A, B)  returns true if A and B are both
%   scalar NaN. Otherwise, returns false
% ----------
%   Inputs:
%       A: The first input being tested
%       B: The second input being tested
%
%   Outputs:
%       tf (scalar logical): True if A and B are both scalar NaN. Otherwise
%           false
%
%   <a href="matlab:dash.doc('dash.metadata.bothNaN')">Online Documentation</a>

if isnumeric(A) && isnumeric(B) && isscalar(A) && isscalar(B) && isnan(A) && isnan(B)
    tf = true;
else
    tf = false;
end

end