function [f,Y, Y_lin] = calc_freq_resp_async(data)
    sigs = data.sig;
    fs  = data.fs;
    cal = data.cal;
    sz = size(sigs,2);
    len = ceil(size(sigs,1)/2);
    sz
    len
    if sz > 1
        ind = 1; 
        Y = zeros(len+1,sz);
        Y_lin = zeros(len+1,sz);
        for sig = sigs
            Y_sym = abs(fftshift(fft(sig(:))));         
            Y_lin(:,ind) = [Y_sym(len); 2*Y_sym(len+1:2*len)]./len;
            if length(cal) > 1
                Y(:,ind) = calc_db(cal(ind),Y_lin,true);
            else
                Y(:,ind) = calc_db(cal,Y_lin,true);
            end
            ind = ind +1
        end
    else
        sig = sigs;
        len = ceil(length(sig)/2);            
        Y_sym = abs(fftshift(fft(sig(:)))); 
        Y_lin = [Y_sym(len); 2*Y_sym(len+1:2*len)]./len;
        Y = calc_db(cal,Y_lin,true);
    end
    f = linspace(0,fs/2,len+1);
end