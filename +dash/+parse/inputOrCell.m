function[input, wasCell] = inputOrCell(input, nEls, name, header)

if nEls>1 || iscell(input)
    dash.assert.vectorTypeN(input, 'cell', nEls, name, header);
    wasCell = true;
else
    input = {input};
    wasCell = false;
end

end