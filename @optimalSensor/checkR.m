function[] = checkR(R, nSite)
% Error checks R inputs

dash.assert.vectorTypeN(R, 'numeric', nSite, 'R');
dash.assert.realDefined(R, 'R');
assert(~any(R<=0), 'R can only include positive values');

end

