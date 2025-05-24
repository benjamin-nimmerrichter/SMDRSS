function [f,Y] = calc_freq_resp_async(data)
    sig = data.sig;
    az  = data.az;
    el  = data.el;
    fs  = data.fs;
    cal = data.cal;
    len = ceil(length(sig)/2);
    x = calc_db(cal,sig,true);
    Y_sym = fftshift(fft(x));
    Y_lin = abs(Y_sym(len:2*len));
    Y = 
    f = linspace(0,fs/2,len+1);
end