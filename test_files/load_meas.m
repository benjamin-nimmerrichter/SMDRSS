function meas = load_meas(name)
strcat("measurement\",name)
if exist(name,"file") 
    if endsWith(name,"_m.mat")
        meas = load(name);
        return
    end
end
meas = struct([]);
end