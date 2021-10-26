function[] = buildDocs

source = 'C:\Users\jonki\Documents\MATLAB\DASH\doc_source\sphinx-source-rst';
build = 'C:\Users\jonki\Documents\MATLAB\DASH\doc_source\html';
command = sprintf('sphinx-build -a %s %s', source, build);
system(command);

end