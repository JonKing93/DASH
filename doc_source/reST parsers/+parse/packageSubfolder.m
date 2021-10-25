function[subfolder] = packageSubfolder(help)
title = parse.packageTitle(help);
subfolder = split(title, ".");
subfolder = subfolder(end);
end