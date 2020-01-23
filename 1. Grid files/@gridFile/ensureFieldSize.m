function[m] = ensureFieldSize( m, s, counter )
% Checks that newly added fields do not exceed preallocated values.
% Preallocates more space if so.


maxSize = [size(m,'sourcePath',2), size(m,'sourceFile',2), size(m,'sourceVar',2), ...
                size(m,'sourceDims',2), size(m,'sourceOrder',2), size(m,'sourceSize',2), ...
                size(m,'unmergedSize',2), size(m,'merge',2), size(m,'unmerge',2)];
            
% Mark the field associated with each counter
field = ["sourcePath","sourceFile","sourceVar","sourceDims","sourceOrder",...
         "sourceSize","unmergedSize","merge","unmerge"];
            
% Mark which preallocation value to use for each field
preField = ["prePathChar","preFileChar","preVarChar","preDimChar",...
             "preDimChar","preDims","preDims","preDims","preDims"];
         
% Add space for more sources
maxSource = size(m,'dimLimit',3); %#ok<*GTARG>
if s > maxSource
    newSource = maxSource+1 : maxSource+gridFile.preSource;
    m.dimLimit(:,:,newSource) = NaN;
    m.sourcePath(newSource,:) = ' ';
    m.sourceFile(newSource,:) = ' ';
    m.sourceVar(newSource,:)  = ' ';
    m.sourceDims(newSource,:) = ' ';
    m.sourceOrder(newSource,:) = ' ';
    m.sourceSize(newSource,:) = NaN;
    m.unmergedSize(newSource,:) = NaN;
    m.merge(newSource,:) = NaN;
    m.unmerge(newSource,:) = NaN;
end

% Add space for any fields that are too short
for k = 1:numel(counter)
    if counter(k) > maxSize(k)
        fillValue = ' ';
        if k > 5
            fillValue = NaN;
        end
        
        m.(field(k))(:, maxSize(k)+1:counter(k)+gridFile.(preField(k))) = fillValue;
    end
end
      
end