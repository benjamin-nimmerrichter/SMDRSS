function rms_vals = calibrate_func(Fs,mics,buffsz,pr)
% App handle
h_figs = findall(0,'Type','Figure'); % handle to all figures
h_app = h_figs.RunningAppInstance; % handle to open app
cal_vect = false(mics,1);
h_app.cal_vect = cal_vect;
h_app.upd_calib_table();

if (buffsz >= 1024)
   len = 16; 
end
if (buffsz < 1024 && buffsz >= 512)
   len = 32; 
end
if (buffsz < 512 && buffsz >= 256)
   len = 64; 
end
if (buffsz < 256)
   len = 128; 
end
write = uint8(0);
offset = uint8(4);
buffers = uint8(len-1);
one = uint8(1);
in = zeros(buffsz,2);
hold = zeros(mics,1);
calib = zeros(mics,1);
rms_vals = zeros(mics,1);

done = false;
buff= zeros(buffers+one,buffsz,mics);
array = zeros((buffsz*len),mics);

while (~done)
    out = pr(in(:,:));
    buff((write + one),:,:) = out;
    write = bitand((write + one),buffers);
    read = bitand((write + offset),buffers);

    if (read == uint8(len-1))
        array(1:buffsz,:) = buff(1,:,:);
        for i = 2:len
            array(buffsz*(i-1):(buffsz*i-1),:) = buff(i,:,:);
        end
        avg_diff = zeros(mics,1);
        for N = 1:mics
            if (max(array(:,N)) > 0.01)               
                autoc(:,N) = xcorr(array(:,N),array(:,N));
                auto_m = max(autoc(:,N));
                autoc(:,N)=autoc(:,N)./auto_m;
                autoc(autoc<0.8) = 0;
                [~,locs] = findpeaks(autoc(:,N));
                amt = length(locs);
                diff = zeros(amt,1);
                if amt < 5
                    avg_diff(N) = 0;
                else
                    for pk=1:amt-2
                        diff(pk)=locs(pk+1)-locs(pk);
                    end
                    avg_diff(N) = sum(diff)/amt;
                end              
            end
        end
        freqs = (Fs./avg_diff);
        freqs(freqs>1400)=0;
        freqs(freqs<600)=0;
        for num = 1:mics
            if calib(num) == 0
                if freqs(num) ~= 0
                    hold(num) = hold(num)+1;
                else
                    hold(num) = 0;
                end
                if hold(num) == 4
                    rms = calc_rms2(array(:,num));
                    if (rms) > 0.01 % -40 dbFS 
                        rms_vals(num) = rms;
                        calib(num) = 1;
                        cal_vect(num) = true; 
                    end
                end
            end
        end
        h_app.cal_vect = cal_vect;
        h_app.upd_calib_table();
    end    
    if (sum(calib) >= mics)
        done = true;
    end
end