function[] = docFunction(title, examples)
exampleFile = strcat(examples, ".md");
write.functionRST(title, exampleFile);
end
