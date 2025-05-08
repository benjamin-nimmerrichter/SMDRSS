function db_val = calc_db(x0,xm,spl)
%CALC_DB calculates DB based on ref. value
    if (spl)
        db_val = 20*log10(xm./x0) + 94; % assuming calibrated values at 94 dBSPL
    else
        db_val = 20*log10(xm./x0); % just calculating the ratio
    end
end