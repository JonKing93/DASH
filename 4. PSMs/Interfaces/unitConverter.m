classdef unitConverter < handle
    
    %% This is an interface for unit conversion. It allows all PSMs to access
    % unit conversion with the single line "convertUnits".
    
    % Right now, this is pretty basic, but feel free to add more features!
    
    properties
        addUnit;
        multUnit;
    end
    
    methods
        
        % Constructor. Automatically called upon PSM creation. Does not
        % need to be called explicitly.
        function obj = unitConverter()
        end
        
        % Convert units
        function[M] = convertUnits( obj, M )
            M = M + obj.addUnit;
            M = M .* obj.multUnit;
        end
        
        % Error checking and default parameters.
        function[] = reviewUnitConversion(obj, H)
            
            % Get the number of state elements
            nEls = numel(H);
            
            % Set defaults
            if isempty(obj.addUnit)
                obj.addUnit = zeros( size(H) );
            end
            if isempty(obj.multUnit)
                obj.multUnit = ones( size(H) );
            end
            
            % Convert row to column
            if isrow(obj.addUnit)
                obj.addUnit = obj.addUnit';
            end
            if isrow(obj.multUnit)
                obj.multUnit = obj.multUnit';
            end
            
            % Check the length
            if ~isvector(obj.addUnit) || length(obj.addUnit)~=nEls
                error('addUnit must be a vector with 1 element per sampling index (%0.f)', numel(obj.H));
            elseif ~isvector(obj.multUnit) || length(obj.multUnit)~=nEls
                error('multUnit must be a vector 1 element per sampling index (%0.f)'
            end
        end
    end
end