function[] = buildStateVectorTestdata

meta = gridMetadata('lon', rand(100,3), 'lat', (1:20)', 'time', datetime(1:1000,1,1)');
meta = meta.edit('run', ["Full";"Volcanic";"GHG"]);
gridfile.new('test-lltr', meta, true);

end
