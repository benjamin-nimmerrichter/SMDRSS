close all
synthetic = 0; %set if sound is syntethized
Fs = 48000;
A = 0.5;
time = 0.2;
f = 1000;
n = 1:Fs*time;
R = 8;
t = linspace(0,time,time*Fs);
t2 = linspace(0,time,time*Fs/R);

if (synthetic)
    sig = gen_sound();
else
    pr = audioPlayerRecorder;
    sig = rec_sound();
end
% filter
sigf = CIC(sig,R);

autoc = xcorr(sigf,sigf);
figure
plot(t,sig);

figure
plot(t2,sigf);
auto_ans = abs(autoc);

figure
plot(auto_ans);

[pks,~] = findpeaks(auto_ans);
[m_val,~] = max(pks);

for val = 1:length(auto_ans)
    if auto_ans(val) < 0.7*m_val
        auto_ans(val) = 0;
    end
end

figure
plot(auto_ans);

[pks,locs] = findpeaks(auto_ans);
[m_val,m_ind] = max(pks);

half = m_ind;
diff = zeros(8,1);
for i = 1:8
    diff(i) = abs(locs(half+(i-4))-locs(half+(i-3)));
end
n_diff = mean(diff);
f_diff = Fs/(R*n_diff);

release(pr);

function out = gen_sound()
    noise = 0.7*rand(Fs*time,1);
    sig = A*cos(2*pi*f*n/Fs);
    sig2 = 0.5*A*cos(8*pi*f*n/Fs);
    out = sig(:)+noise(:)+sig2(:);
end

function out = rec_sound()
 out = zeros(512,1);

 pr.getAudioDevices
 
end