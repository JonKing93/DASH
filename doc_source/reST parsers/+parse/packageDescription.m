function[details] = packageDescription(help)

description = get.packageDescription(help);

details = strings(0,1);
p = 0;
new = true;

eol = [0, find(description==10)];
for k = 2:numel(eol)
    line = description(eol(k-1)+1:eol(k));
    hasinfo = any(~isspace(line(2:end)));

    if hasinfo
        line = strip(line, 'right');
        line = line(5:end);
        line = string(line);
        
        if new
            details = cat(1, details, line);
            p = p+1;
            new = false;
        else
            details(p) = strcat(details(p), " ", line);
        end
        
    else
        new = true;
    end 
end

end