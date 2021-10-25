function[] = build_template_docs

source = 'C:\Users\jonki\Documents\MATLAB\DASH\doc_source\templates';
build = 'C:\Users\jonki\Documents\MATLAB\DASH\doc_source\templates\html-build';
html = 'C:\Users\jonki\Documents\MATLAB\DASH\doc_source\templates\html-build\index.html';

command = sprintf('sphinx-build -a %s %s', source, build);
system(command);
web(html, '-browser');

end