function[newfile] = filename(title, saveIn)
name = parse.name(title, true);
newfile = [saveIn, filesep, char(name), '.rst'];
end