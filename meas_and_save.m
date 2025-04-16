close all
clearvars
Fs = 48000;
time = 0.1;
channels = 4;
pr = audioPlayerRecorder(Fs,"BitDepth","16-bit integer","PlayerChannelMapping",1:1,"RecorderChannelMapping",1:channels,"Device","M-Audio Fast Track Ultra ASIO");
buff_sz = pr.BufferSize;
buff_amt = ceil(time*(Fs/buff_sz)); 
in = zeros(buff_sz,1);
out = zeros(buff_sz*buff_amt,channels);
for N = 1:buff_amt
    lower = (N-1)*buff_sz+1;
    upper = (N)*buff_sz;
    out(lower:upper,1:channels) = pr(in(:));
end
release(pr);
figure(1);
plot(out);
ax = gca;
ax.YLim = [-1 1];
avg_diff = zeros(channels,1);

for N = 1:channels
    autoc(:,N) = xcorr(out(:,N),out(:,N));
    auto_m = max(autoc(:,N));
    autoc(:,N)=autoc(:,N)./auto_m;
    autoc(autoc<0.9) = 0;
    [pks,locs] = findpeaks(autoc(:,N));
    amt = length(locs);
    if amt < 5
        avg_diff(N) = 0;
    else
        for pk=1:amt-2
            diff(pk)=locs(pk+1)-locs(pk);
        end
        avg_diff(N) = sum(diff)/amt;
    end
end
figure(2)
plot(autoc);
freqs = (Fs./avg_diff);
freqs(freqs>1200)=0;
freqs(freqs<800)=0;
freqs

sel = input("Would you like to save the recording? y/n \n","s");
switch sel
    case {'y','Y'}
    name = input("Write the recording name:\n","s");
    disp(name);
    writematrix(out,strcat(name,"_raw_out_",num2str(Fs),"Hz.txt"))
    writematrix(autoc,strcat(name,"_autoc_out_",num2str(Fs),"Hz.txt"))
    otherwise
    disp('Did not save')
end