clear all
close all

Fs = 48000;
cfg = load('../MERENI 360 po 5\konfigurace\meas_config.mat');
signal1 = load('../MERENI 360 po 5\meas1_main_test_n_0.mat').signal; %onax
signal2 = load('../MERENI 360 po 5\meas1_main_test_n_37.mat').signal; %zada
freqs = linspace(0,Fs/2,50048/2)';

figure
Y1 = fft(signal1);
plot(freqs, abs(Y1(1:length(Y1)/2,:)))
figure
Y2 = fft(signal2);
plot(freqs, abs(Y2(1:length(Y2)/2,:)))
start = 20000;
size = 1000;
Y1_RMS = calc_rms2(abs(Y1(start:(start+size),:)))';
Y2_RMS = calc_rms2(abs(Y2(start:(start+size),:)))';

Y1_DB = calc_db(cfg.calib,Y1_RMS,true);
Y2_DB = calc_db(cfg.calib,Y2_RMS,true);
theta = linspace ((-30/180)*pi,(30/180)*pi,7);

figure
polarplot(theta,Y1_DB,"g");
hold on
polarplot(theta,Y2_DB,"r");
hold off
legend('Front','Rear')