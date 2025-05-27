close all
clearvars

% record 1s of sound
% clearvars
% devID = 1;
% Fs = 48000;
% rec = audiorecorder(Fs,16,1);
% record(rec)
% pause(5)
% stop(rec)
% pause(0);
% x = getaudiodata(rec);
% pause(0);
% apl = audioplayer(x,48000,16);

if ~exist("x","var")
load('1k_test.mat')
x = x(50000:end);
end

Fs = 48000;
T = length(x)/Fs;
t = linspace(0,T,length(x));

% fft
X = fftshift(fft(x));
len = length(X);
half = round(len/2);
freqs = linspace(0,Fs/2,half+1);
X_half = abs(X(half:end));
X_max = max(X_half);
X_norm = X_half./X_max;
db_values = calc_db(1,X_norm,false);

% cros correlation
C = xcorr(x,x);
C_max = max(C);
C = C./C_max;

% trim excess
f = 1000;   % expected frequency in Hz
SPP = Fs/f; % samples per peak
ENP = 5;    % expected number of peaks
len = length(C);

offs = round((SPP*ENP)/2);
sams = linspace(0,2*offs,2*offs+1);
from = round(len/2-offs);
to = round(len/2+offs);
C_trim = C(from:to);

% normalize
C_max = max(C_trim);
%C_norm = C_trim./C_max;
C_rect = C_trim;
% delete negative values
C_rect(C_rect < 0) = 0;

% find freq
[~,locs] = findpeaks(C_trim);
for i = 2:length(locs)
    delta = locs(i)-locs(i-1);
end
avg_delta = mean(delta);
freq = Fs/avg_delta;

% styling
%fontsize(30,"points")
%figure(1)
%plot(t,x,"k")
%title("Measured signal")
%ylabel('Signal Value [-] \rightarrow')
%xlabel('Time [s] \rightarrow')

%figure(2)
%stem(t(1:2*offs),x(1:2*offs),"k")
%grid on
%title("Measured signal close up")
%ylabel('Signal Value [-] \rightarrow')
%xlabel('Time [s] \rightarrow')

figure(3)
plot(C,"k")
title("Autokorelační funkce měřeného signálu")
ylabel('Hodnota signálu [-] \rightarrow')
xlabel('Vzorky [-] \rightarrow')

figure(4)
stem(sams,C_trim,"k")
grid on
title("Ořezaná a normalizovaná autokorelační funkce")
ylabel('Hodnota signálu [-] \rightarrow')
xlabel('Vzorky [-] \rightarrow')

%figure(5)
%stem(sams,C_norm,"k")
%grid on
%title("Ořezaná autokorelační funkce")
%ylabel('Hodnota signálu [-] \rightarrow')
%xlabel('Vzorky [-] \rightarrow')

figure(6)
stem(sams,C_rect,"k")
title("Jednocestně usměrněná autokorelační funkce")
ylabel('Hodnota signálu [-] \rightarrow')
xlabel('Vzorky [-] \rightarrow')

figure(7)
semilogx(freqs,db_values,"k")
hold on
grid on
xlabel('Kmitočet [Hz] \rightarrow')
ylabel('Hodnota signálu [dB(FS)] \rightarrow')
%yticks(50:5:110)
title("Spektrum testovacího signálu")
core = [2 3 5 10];
xticks([core.*10 core.*100 core.*1000 20000])
xlim([20 20E3])
ylim([-70 0])
%fontsize(20,"points") 
