function[] = checkR(R, nSite)
% Error checks R inputs

dash.assertVectorTypeN(R, 'numeric', nSite, 'R');
dash.assertRealDefined(R, 'R');
assert(~any(R<=0), 'R can only include positive values');

end

