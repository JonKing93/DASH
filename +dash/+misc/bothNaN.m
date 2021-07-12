function[tf] = bothNaN(A, B)
%% Tests if two inputs are both NaN.
tf = false;
if isnumeric(A) && isnumeric(B) && isscalar(A) && isscalar(B) && isnan(A) && isnan(B)
    tf = true;
end
end