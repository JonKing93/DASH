function[limits] = limits(nEls)

last = cumsum(nEls);
first = [1; last(1:end-1)+1];
limits = [first, last];

end