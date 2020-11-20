classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Analysis
        dist = haversine(latlon1, latlon2);
        
        % Misc
        [names, lon, lat, coord, lev, time, run, var]  = dimensionNames;
        convertToV7_3(filename);
        [X, order] = permuteDimensions(X, index, iscomplete, nDims);
        tf = bothNaN(A, B);
        s = loadMatfileFields(file, fields, extName);
        
        % Input parsing
        varargout = parseInputs(inArgs, flags, defaults, nPrev);
        [input, wasCell] = parseInputCell(input, nDims, name);
        input = parseLogicalString(input, nDims, logicalName, stringName, allowedStrings, lastTrue, name);
        index = parseListIndices(input, strName, indexName, list, listName, lengthName, inputNumber, eltNames);
        
        % Structures
        [s, inputs] = preallocateStructs(fields, siz);
        values = collectField(s, field);
        
        % Files
        path = checkFileExists(file);  
        path = unixStylePath(path);
        path = relativePath(toFile, fromFolder);
        filename = setupNewFile(filename, ext, overwrite);
        
        % Strings and string lists
        tf = isstrflag( input );        
        tf = isstrlist( input );
        input = assertStrFlag(input, name);
        input = assertStrList(input, name);
        k = checkStrsInList(input, list, name, message);
        str = messageList(list);
        
        % Input assertions
        assertScalarType(input, name, type, typeName);
        assertRealDefined(input, name, allowNaN, allowInf, allowComplex);
        assertVectorTypeN(input, type, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        
        % Indices
        indices = checkIndices(indices, name, dimLength, dimName);
        indices = equallySpacedIndices(indices);
    end
    
end
        