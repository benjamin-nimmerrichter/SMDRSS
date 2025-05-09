function rms_vals = calibrate_func(Fs,mics,buffsz,pr,cal_freq)
% App handle
h_figs = findall(0,'Type','Figure'); % handle to all figures
h_app = h_figs.RunningAppInstance; % handle to open app
cal_vect = false(mics,1);
h_app.cal_vect = cal_vect;
h_app.upd_calib_table();

% frequency range
upper = cal_freq + 50;
lower = cal_freq - 50;

% trim options
SPP = Fs/cal_freq; % samples per peak
ENP = 5;   % expected number of peaks
offs = round((SPP*ENP)/2); % offset of samples

% keep recording time long enough for different buffer sizes
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

% trim values
num_samples = len*buffsz;
from = round(num_samples/2-offs);
to = round(num_samples/2+offs);

% init of values
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

    % record audio
    out = pr(in(:,:));
    buff((write + one),:,:) = out;

    % read write "pointers"
    write = bitand((write + one),buffers);
    read = bitand((write + offset),buffers);
    
    % check every 8 buffers, to cut down on processing
    if (bitand(read,8) > 0) % it can be only 2^n to work
        array(1:buffsz,:) = buff(1,:,:); % load first buffer into array
        % load rest of buffers into array
        for i = 2:len
            array(buffsz*(i-1):(buffsz*i-1),:) = buff(i,:,:);
        end
        % reset avg_diff
        avg_diff = zeros(mics,1);

        for mic = 1:mics
            if (max(array(:,mic)) > 0.01)   
                % calculate autocorrelation
                autoc = xcorr(array(:,mic),array(:,mic));
                % trim autocorrelation function 
                %  - this reduces CPU and memory usage
                autoc = autoc(from:to);
                % rectify signal
                autoc(autoc<0) = 0;
                % find peaks in signal
                [~,locs] = findpeaks(autoc);
                amt = length(locs);
                diff = zeros(amt,1);                
                if amt < 5
                    % if there's too little peaks reset
                    avg_diff(mic) = 0;
                else
                    % find difference between peaks
                    for pk = 1:amt-2
                        diff(pk)=locs(pk+1)-locs(pk);
                    end
                    avg_diff(mic) = mean(diff);
                end              
            end
        end

        % calculate and check frequency
        freqs = (Fs./avg_diff);
        freqs(freqs>upper)=0;
        freqs(freqs<lower)=0;

        % chceck if 1000 Hz is detected long enough
        for mic = 1:mics
            if calib(mic) == 0
                if freqs(mic) ~= 0
                    hold(mic) = hold(mic)+1;
                else
                    hold(mic) = 0;
                end
                if hold(mic) == 5
                    % calculate RMS value
                    rms = calc_rms2(array(:,mic));
                    if (rms) > 0.005 % -46 dbFS 
                        rms_vals(mic) = rms;
                        calib(mic) = 1;
                        cal_vect(mic) = true; 
                    end
                end
            end
        end
        h_app.cal_vect = cal_vect;
        h_app.upd_calib_table();
    end  % bitand(read,8) > 0

    % if all mics are calibrated, finish
    if (sum(calib) >= mics)
        done = true;
    end
end