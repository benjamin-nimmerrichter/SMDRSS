function meas_out = meas_func(Fs,mics,buffsz,pr,sig,sig_Fs,attenuation)

sig = [sig; zeros(buffsz*2,1)];

sig = attenuation.*sig;
if (Fs ~= sig_Fs)
    [P,Q] = rat(sig_Fs/Fs);
    sig = resample(sig,P,Q);
end

samples = length(sig);
out = zeros(samples,mics);
sig = [sig sig]; %stereo in
%% MAIN PART

counter = 0;
while (true)
    counter = counter + 1;
    if (buffsz*counter > samples)
        break;
    end
    inp = sig((buffsz*(counter-1)+1):(buffsz*counter),:);
    out((buffsz*(counter-1)+1):(buffsz*counter),:) = pr(inp(:,:));
end
meas_out = out;
return