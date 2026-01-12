function success = save_config(config,name)
name = fname_processor(".xml","_c", name);
path = strcat("../config_files/",name);
writestruct(config,path)
if exist(path,"file") 
    success = 1;
    return
end
success = 0;
end