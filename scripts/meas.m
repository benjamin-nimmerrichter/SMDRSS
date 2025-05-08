%% INPUT
Fs = 48000;
mics = 1;
buffsz = 512;
len = 4; % 2^n
[sig,Fs1] = audioread('test.wav');
sig = [sig; zeros(buffsz*2,1)];
pr = audioPlayerRecorder(Fs, ...
                        "BitDepth","16-bit integer", ...
                        "PlayerChannelMapping",1:1, ...                        
                        "Device","ASIO4ALL v2"); %M-Audio Fast Track Ultra ASIO %"RecorderChannelMapping",1:mics


if (Fs ~= Fs1)
    [P,Q] = rat(Fs1/Fs);
    sig = resample(sig,P,Q);
end
samples = length(sig);
time = samples/Fs;
out = zeros(samples,mics);
%% MAIN PART

counter = 0;
while (true)
    counter = counter + 1;
    if (buffsz*counter > samples)
        break;
    end
    in = sig((buffsz*(counter-1)+1):(buffsz*counter));
    out((buffsz*(counter-1)+1):(buffsz*counter),:) = pr(in);
end

noise_rms = calc_rms2(out);

plot(out);