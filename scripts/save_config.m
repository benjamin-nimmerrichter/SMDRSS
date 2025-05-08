function success = save_config(config,name)
name = fname_processor(".xml","_c", name);
writestruct(config,name)
if exist(name,"file") 
    success = 1;
    return
end
success = 0;
end