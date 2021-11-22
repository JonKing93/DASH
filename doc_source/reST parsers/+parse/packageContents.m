function[sections, sectsummaries, headings, files, h1] = packageContents(header)
%%
% sections: reST section headings. The first element is empty
% sectionType: Section types
%   1. ** - Do not add to toc, titlecase
%   2.  * - Add section headings to toc
%   3. == - Add methods to toc, ignore headings
% summaries: reST section descriptions. The first element is empty
% headings (cell vector of string vectors): html sub-headings placed in
%   each reST section
% files (cell vector{cell vector{string vector}}): The files in each html
%   heading
% h1 (cell vector{cell vector{string vector}}): The H1 description for each
%   file

% Get the details section
details = get.details(header);
details = [details, newline];

% Preallocate reST sections
sections = "";
summaries = "";
headings = {""};
files = {{strings(0,1)}};
h1 = {{strings(0,1)}};
s = 1;
h = 1;
inSummary = false;

% Get each line of text
eol = [0, find(details==10)];
for k = 2:numel(eol)
    line = details(eol(k-1)+1:eol(k));
    [line, hastext] = parse.line(line, 3);
    line = char(line);
    
    % Ignore blank lines and doc links
    if ~hastext || contains(line, '<a href=')
        % Do nothing
    
    % New reST section
    elseif line(1)=='*' && line(2)=='*'
        s = s+1;
        h = 1;
        sections(s) = line(3:end-2);
        summaries(s) = "";
        headings{s} = "";
        files{s} = {strings(0,1)};
        h1{s} = {strings(0,1)};
        
        inSummary = true;
        
    % HTML heading
    elseif line(end)==':'
        h = h+1;
        headings{s}(end+1) = line(1:end-1);
        files{s}{h} = strings(0,1);
        h1{s}{h} = strings(0,1);
        inSummary = false;
        
    % Content line
    elseif length(line)>=2 && all(isspace(line(1:2))) && contains(line, ' -')
        line = line(3:end);
        inSummary = false;
        
        firstSpace = find(line==' ',1);
        files{s}{h}(end+1) = line(1:firstSpace-1);
        
        firstHyphen = find(line=='-', 1);
        h1{s}{h}(end+1) = line(firstHyphen+2:end);
        
    % Continuing summary
    elseif inSummary
        if strcmp(summaries(s), "")
            summaries(s) = line;
        else
            summaries(s) = strcat(summaries(s), " ", line);
        end
        
    % Anything else
    else
        error('Unknown contents syntax');
    end
end

end
        