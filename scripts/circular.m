%% INPUT
Fs = 48000;
mics = 3;
buffsz = 512;
len = 4; % 2^n
pr = audioPlayerRecorder(Fs, ...
                        "BitDepth","16-bit integer", ...
                        "PlayerChannelMapping",1:1, ...
                        "RecorderChannelMapping",1:mics, ...
                        "Device","M-Audio Fast Track Ultra ASIO");

%% MAIN PART
write = uint8(0);
read = uint8(0);
offset = uint8(3);
buffers = uint8(len-1);
one = uint8(1);
cycles = 0;
in = zeros(1,buffsz);
hold = zeros(mics,1);
calib = zeros(mics,1);
const = zeros(mics,1);

done = false;
buff= zeros(buffers+one,buffsz,mics);
array = zeros((512*len),3);
avg_diff = zeros(mics,1);

while (~done)
    out = pr(in(:));
    buff((write + one),:,:)= out;
    write = bitand((write + one),buffers);
    read = bitand((write + offset),buffers);

    if (read == uint8(len-1))
        array(1:512,:) = buff(1,:,:);
        for i = 2:len
            array(buffsz*(i-1):(buffsz*i-1),:) = buff(i,:,:);
        end
        avg_diff = zeros(mics,1);
        for N = 1:mics
            if (max(array(:,N)) > 0.01)               
                autoc = zeros(buffsz*8-1,mics);
                autoc(:,N) = xcorr(array(:,N),array(:,N));
                auto_m = max(autoc(:,N));
                autoc(:,N)=autoc(:,N)./auto_m;
                autoc(autoc<0.8) = 0;
                [pks,locs] = findpeaks(autoc(:,N));
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
                        const(num) = rms;
                        calib(num) = 1;
                    end
                end
            end
        end
    end
    
    if (sum(calib) >= mics)
        done = true;
    end
end