function[r] = randInterval(a,b,siz)
% r = randInterval(a,b,siz)

r = a + (b-a) .* rand(siz);

end