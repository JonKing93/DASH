function[r] = randInterval(a,b,siz)
%% Generate random values on an interval
%
% r = randInterval(a,b,siz)
%
% ----- Inputs -----
%
% a: The lower bound of the interval
%
% b: The upper bound of the interval
%
% siz: The size of the output array

r = a + (b-a) .* rand(siz);

end