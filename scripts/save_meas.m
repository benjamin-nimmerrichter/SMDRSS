function success = save_meas(meas,name)
    name = fname_processor(".mat","_m", name);
    path = strcat("../measurement_files/",name);
    save(path,"meas")
    if exist(path,"file") 
        success = 1;
        return
    end
    success = 0;
end