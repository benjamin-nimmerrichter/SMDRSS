function success = save_meas(meas,name)
    name = fname_processor(".mat","_m", name);
    save(name,"meas")
    if exist(name,"file") 
        success = 1;
        return
    end
    success = 0;
end