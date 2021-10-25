function[rst] = types(types)
%% reST format for the data type details of a set of inputs/outputs
% ----------
%   rst = format.types(types)
% ----------
%   Inputs:
%       types (string vector): List of data type details
%
%   Outputs:
%       rst (string vector): reST formatting for the data type details

rst = strings(size(types));

% Initialize each line with emphasis
for t = 1:numel(types)
    line = char(types(t));
    out = '';
    
    % Cycle through characters
    inEmphasis = false;
    inBracket = false;
    nChars = numel(line);
    for c = 1:nChars
        
        % Initiate emphasis
        if ~inEmphasis && ~inBracket && isletter(line(c))
            out = [out, '*', line(c)]; 
            inEmphasis = true;
            
        % Begin bracket
        elseif inEmphasis && line(c)=='['
            out = [out(1:end-1), '* ['];
            inBracket = true;
            inEmphasis = false;
            
        % End bracket
        elseif inBracket && line(c)==']'
            out = [out, ']']; %#ok<*AGROW>
            inBracket = false;
            
        % End emphasis with |
        elseif inEmphasis && line(c)=='|'
            out = [out(1:end-1), '* |'];
            inEmphasis = false;
            
        % End emphasis with end of description
        elseif inEmphasis && c==nChars
            out = [out, line(c), '*'];
            
        % Anything else gets pasted directly into output
        else
            out = [out, line(c)];
        end
    end
    
    % Return string format
    rst(t) = string(out);
end

end
        