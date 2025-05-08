function config = load_config(name)
if exist(name,"file") 
    if endsWith(name,"_c.xml")
        config = readstruct(name,"FileType","xml");
        return
    end
end
config = struct([]);
end