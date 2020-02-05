function[] = ensureFieldSize( obj, s, counter )
% Checks that newly added fields do not exceed preallocated values.
% Preallocates more space if so.
%
% s: The source number
%
% counter: The size of each field
            
% Get the fields and preallocation values associated with each size marker
fields = {'sourcePath','sourceFile','sourceVar','sourceDims','sourceOrder',...
         'sourceSize','unmergedSize','merge','unmerge', 'dimLimit'};
nField = numel(fields);
preField = {'prePathChar','preFileChar','preVarChar','preDimChar',...
             'preDimChar','preDims','preDims','preDims','preDims'};
         
% Get the size of each field in the file
m = load( obj.filepath, '-mat', fields{:} );
maxSize = NaN( 1, nField-1 );
for f = 1:nField-1
    maxSize(f) = size( m.(fields{f}), 2 );
end
maxSource = size(m.dimLimit,3);

% If preallocation is needed, get a writable matfile, note if successfully modified
if s>maxSource || any(counter > maxSize)
    m = matfile( obj.filepath, 'Writable', true );
    m.valid = false;
         
    % Note if more sources are needed
    addSource = false;
    if s > maxSource
        newSource = maxSource+1 : maxSource+gridFile.preSource;
        addSource = true;
        m.dimLimit(:,:,newSource) = NaN;
        m.counter(newSource,:) = NaN;
        m.type(newSource,:) = ' ';
    end

    % Get the fill value for each field
    for k = 1:numel(counter)
        fillValue = ' ';
        if k > 5
            fillValue = NaN;
        end

        % Add any new sources
        if addSource
            m.(fields{k})(newSource,:) = fillValue;
        end

        % Lengthen the field if too short
        if counter(k) > maxSize(k)
            newMax = counter(k)+gridFile.(preField{k});
            m.(fields{k})(:, maxSize(k)+1:newMax) = fillValue;
        end
    end
 
    % Successful writing
    m.valid = true;
end
      
end