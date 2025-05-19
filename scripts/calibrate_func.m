function rms_vals = calibrate_func(Fs,mics,buffsz,pr,cal_freq)
% get app handle
h_figs = findall(0,'Type','Figure'); % handle to all figures
h_app = h_figs.RunningAppInstance; % handle to open app
% init calibration vector
cal_vect = false(mics,1);
% send calibraton vector app
h_app.cal_vect = cal_vect;
h_app.upd_calib_table();

% frequency range +- 50 Hz
upper = cal_freq + 50;
lower = cal_freq - 50;

% trim options
SPP = Fs/cal_freq; % samples per peak
ENP = 7;   % expected number of peaks
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
from = round(num_samples/2-2*offs);
to = round(num_samples/2);

% init of values
write = 1;
half_len = round(len/2);

% init of vectors and matrices
in = zeros(buffsz,2);
hold = zeros(mics,1);
calib = zeros(mics,1);
rms_vals = zeros(mics,1);
buffer = zeros(len,mics,buffsz);


% init the while loop variable
done = false;

while (~done)

    % record audio
    out = pr(in(:,:));

    % write audio to buffer
    buffer(write,:,:) = out';

    % increment write "pointer"
    write = mod(write, len)+1;

    % check every len/2 buffers, to cut down on processing
    % between 350 and 150 ms and at 48000 samples/s
    % this sets calib time to max of 2s 
    if (mod(write,half_len) == 0) % check twice per round in circular buffer
        % permute buffer
        perm = permute(buffer, [2 3 1]);

        % put the signal into a 2D matrix
        lin_buff = reshape(perm,mics,[]);
        
        % reset average difference
        avg_diff = zeros(mics,1); 
        for mic = 1:mics
            % if a peak is over -40 dBFS
            if (max(lin_buff(mic,:)) > 0.01)   
                % calculate autocorrelation function
                autoc= xcorr(lin_buff(mic,:),lin_buff(mic,:));
                % trim autocorrelation function 
                %  - this reduces CPU and memory usage
                autoc = autoc(from:to);
                % rectify signal
                autoc(autoc<0) = 0;
                % find peaks in signal
                [~,locs] = findpeaks(autoc);
                % get amount of peaks
                amt = length(locs);
                % reset differences to 0
                diff = zeros(amt-2,1);       
                if amt > 4
                    % find difference between peaks
                    for pk = 1:amt-2
                        diff(pk)=locs(pk+1)-locs(pk);
                    end
                    avg_diff(mic) = mean(diff);
                end              
            end % if (max(lin_buff(mic)) > 0.01)  
        end % for mic = 1:mics
        
        % calculate and check frequency
        freqs = (Fs./avg_diff);  
        freqs(freqs>upper)=0;
        freqs(freqs<lower)=0;
        
        % chceck if 1000 Hz is detected for long enough
        for mic = 1:mics
            if calib(mic) == 0
                if freqs(mic) ~= 0
                    hold(mic) = hold(mic)+1;
                else
                    hold(mic) = 0;
                end
                if hold(mic) == 5
                    % calculate RMS value
                    rms = calc_rms2(lin_buff(mic,:));
                    if (rms) > 0.01 % -40 dBFS 
                        rms_vals(mic) = rms;
                        calib(mic) = 1;
                        cal_vect(mic) = true; 
                    end
                end
            end % if calib(mic) == 0
        end % for mic = 1:mics
        h_app.cal_vect = cal_vect;
        h_app.upd_calib_table();
    end  % if (mod(write,half_len) == 0)

    % if all mics are calibrated, finish
    if (sum(calib) >= mics)
        done = true;
    end
end % while (~done)