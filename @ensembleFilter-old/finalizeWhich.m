function[obj] = finalizeWhich(obj)

if isempty(obj.whichPrior)
    obj.whichPrior = ones(obj.nTime, 1);
end
if isempty(obj.whichR)
    obj.whichR = ones(obj.nTime, 1);
end

end