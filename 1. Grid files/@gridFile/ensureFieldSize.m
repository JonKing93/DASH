function[] = ensureFieldSize( obj, s, counter )
% Checks that newly added fields do not exceed preallocated values.
% Preallocates more space if so.
%
% s: The source number
%
% counter: The size of each field

% Get the maximum size of the fields in the matfile
m = matfile( obj.filepath, 'Writable', true );
maxSize = [size(m,'sourcePath',2), size(m,'sourceFile',2), size(m,'sourceVar',2), ...
           size(m,'sourceDims',2), size(m,'sourceOrder',2), size(m,'sourceSize',2), ...
           size(m,'unmergedSize',2), size(m,'merge',2), size(m,'unmerge',2)];
            
% Get the fields and preallocation values associated with each size marker
field = {'sourcePath','sourceFile','sourceVar','sourceDims','sourceOrder',...
         'sourceSize','unmergedSize','merge','unmerge'};
preField = {'prePathChar','preFileChar','preVarChar','preDimChar',...
             'preDimChar','preDims','preDims','preDims','preDims'};
         
% Note if the file is unsuccessfully modified
m.valid = false;
         
% Note if more sources are needed
maxSource = size(m,'dimLimit',3); %#ok<*GTARG>
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
        m.(field{k})(newSource,:) = fillValue;
    end
    
    % Lengthen the field if too short
    if counter(k) > maxSize(k)
        newMax = counter(k)+gridFile.(preField{k});
        m.(field{k})(:, maxSize(k)+1:newMax) = fillValue;
    end
end
 
% Successful writing
m.valid = true;
      
end