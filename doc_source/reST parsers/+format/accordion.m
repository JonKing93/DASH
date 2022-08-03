function[rst] = accordion(label, content, handle, checked)
%% reST markup for a collapsible accordion
% ----------
%   rst = format.accordion(label, content, handle, checked)
% ----------
%   Inputs:
%       label (string scalar): The title of the accordion
%       content (string scalar): The accordion content
%       handle (string scalar): Accordion ID
%       checked (scalar logical): Whether the accordion is open by default
%
%   Outputs:
%       rst (string scalar): Formatted markup of the accordion

% Default checked or unchecked
checkStr = '';
if checked
    checkStr = ' checked="checked"';
end

% Get the header
header = sprintf([...
    '<section class="accordion"><input type="checkbox" name="collapse" ',...
    'id="%s"%s><label for="%s"><strong>%s</strong></label><div class="content">'],...
    handle, checkStr, handle, label);
header = string(header);

% Format collapsible accordion
rst = strcat(...
    ".. raw:: html",         '\n',...
                             '\n',...
    "    ",header,           '\n',...
                             '\n',...
    content,                      ... % trailing whitespace
                             '\n',...
    '.. raw:: html',         '\n',...
                             '\n',...
    '    </div></section>',  '\n'...
    );

end
    