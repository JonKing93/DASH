function[] = buildSVVtestdata

meta = gridMetadata('lon', rand(100,3), 'lat', (1:20)', 'time', datetime(1:1000,1,1));
gridfile.new('test-llt', meta, true);

meta = meta.edit('run', ["Full";"Volcanic";"GHG"]);
gridfile.new('test-lltr', meta, true);

meta = gridMetadata(["lat","lon","time","run"], {1,1,1,1});
gridfile.new('test-lltr-different-size', meta, true);

end