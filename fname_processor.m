function name = fname_processor(ext,suffix,nameIn)
fin = strcat(suffix,ext); %whole end of filename
if endsWith(nameIn, fin) %if it does end with suffix.xml
    name = nameIn;
    return
else %if it does not end with suffix.xml
    if endsWith(nameIn, suffix) % if it ends with suffix, but not extension
        name = strcat(nameIn,ext);
        return
    end
    if endsWith(nameIn, ext) % if it ends with extension but not suffix
        temp = erase(nameIn,ext);
        name = strcat(temp,fin);
        return
    end
    name = strcat(nameIn,fin);
end
end