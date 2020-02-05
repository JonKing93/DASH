function[m, newVars] = ensureFieldSize( m, newVars )

% Get the size of the new variables and save variables
newCount = NaN( 1,9 );
for k = 1:9
    newCount(k) = numel( newVars{k} );
end
saveCount = m.counter;

% Don't bother for a new file
if ~all( saveCount==0 )

    % Mark which variables need increasing
    addToNew = find( newCount < saveCount );
    addToSaved = find( saveCount < newCount );

    % Preallocate space for new variables
    nAdd = saveCount(addToNew) - newCount(addToNew);
    for k = 1:numel(addToNew)
        if addToNew(k) <= 5
            newVars{addToNew(k)}(:, end+(1:nAdd(k))) = ' ';
        else
            newVars{addToNew(k)}(:, end+(1:nAdd(k))) = NaN;
        end
    end

    % Preallocate space for saved variables
    nAdd = newCount(addToSaved) - saveCount(addToSaved);
    fields = {'sourcePath','sourceFile','sourceVar','sourceDims','sourceOrder', ...
              'sourceSize','unmergedSize','merge','unmerge'};
    for k = 1:numel(addToSaved)
        if addToSaved(k) <= 5
            m.(fields{addToSaved(k)})(:, end+(1:nAdd(k))) = ' ';
        else
            m.(fields{addToSaved(k)})(:, end+(1:nAdd(k))) = NaN;
        end
    end
end

% Update the counter
m.counter = max( [newCount; saveCount] );

end
    