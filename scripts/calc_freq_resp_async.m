function [f,Y] = calc_freq_resp_async(data)
    sig = data.sig;
    az  = data.az;
    el  = data.el;
    fs  = data.fs;
    cal = data.cal;

    len = ceil(length(sig)/2);
    Y_sym = abs(fftshift(fft(sig)));
    Y_lin = 2*Y_sym(len:2*len)/len;
    Y = calc_db(cal,Y_lin,true);
  
    f = linspace(0,fs/2,len+1);
    Y(1:20)
    f(1:20)
end