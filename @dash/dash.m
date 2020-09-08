classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Misc
        names = dimensionNames;
        varargout = parseInputs(inArgs, flags, defaults, nPrev);
        convertToV7_3(filename);
        X = permuteToOrder(X, order, nDims);
        
        % Structures
        [s, inputs] = preallocateStructs(fields, siz);
        values = collectField(s, field);
        
        % File paths
        path = checkFileExists(file);  
        path = unixStylePath(path);
        path = relativePath(toFile, fromFolder);
        
        % Strings and string lists
        tf = isstrflag( input );        
        tf = isstrlist( input );
        input = assertStrFlag(input, name);
        input = assertStrList(input, name);
        k = checkStrsInList(input, list, name, message);
        str = messageList(list);
        
        % Input assertions
        assertScalarLogical(input, name);
        assertRealDefined(input, name, allowNaN, allowInf, allowComplex);
        assertVectorTypeN(input, type, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        
        % Indices
        indices = checkIndices(indices, name, dimLength, dimName);
        indices = equallySpacedIndices(indices);
    end
    
end
        