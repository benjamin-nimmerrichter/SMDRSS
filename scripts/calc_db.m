function db_val = calc_db(x0,xm,ref)
%CALC_DB calculates DB based on ref. value
    db_val = 20*log10(xm./x0) + ref; 
end