close all
clc
clear all
A = 1;
Fs = 44100;
f = 1000;
num_per = 100;


n_per = linspace(0,round(Fs/f)-1,round(Fs/f));
period = A*cos(2*pi*f*n_per/Fs);
out = period;
for per = 1:num_per
    out = horzcat(out,period);
end
figure
stem(out);
X = fftshift(fft(out));
figure
frq = linspace(-Fs/2,Fs/2,length(X));
plot(frq, abs(X));
