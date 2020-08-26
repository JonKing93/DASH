classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Misc
        names = dimensionNames;
        varargout = parseInputs(inArgs, flags, defaults, nPrev);
        convertToV7_3(filename);
        
        % File paths
        path = checkFileExists(file);  
        path = unixStylePath(path);
        path = relativePath(toFile, fromFolder);
        
        % Strings and string lists
        tf = isstrflag( input );        
        tf = isstrlist( input );
        assertStrFlag(input, name);
        assertStrList(input, name);
        k = checkStrsInList(input, list, name, message);
        str = errorStringList(strings);
        
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
        