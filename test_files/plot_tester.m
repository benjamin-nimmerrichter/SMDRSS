%% Test vykreslování
clear all;
close all;
%% Ingest dat
%PWD = pwd;
calib = load("Měření 14-11\meas_config_mic_na_rameni.mat").calib;
sig_1 = load("Měření 14-11\90 stupnu\meas1_main_test_n_0.mat").signal;
sig_2 = load("Měření 14-11\90 stupnu\meas1_main_test_n_1.mat").signal;
sig_3 = load("Měření 14-11\90 stupnu\meas1_main_test_n_2.mat").signal;
sig_4 = load("Měření 14-11\90 stupnu\meas1_main_test_n_3.mat").signal;
sig_5 = load("Měření 14-11\90 stupnu\meas1_main_test_n_4.mat").signal;
sig_6 = load("Měření 14-11\90 stupnu\meas1_main_test_n_5.mat").signal;
sig_7 = load("Měření 14-11\90 stupnu\meas1_main_test_n_6.mat").signal;
sig_8 = load("Měření 14-11\90 stupnu\meas1_main_test_n_7.mat").signal;
sig_9 = load("Měření 14-11\90 stupnu\meas1_main_test_n_8.mat").signal;
sig_10 = load("Měření 14-11\90 stupnu\meas1_main_test_n_9_onax.mat").signal;

multichannel = [sig_1 sig_2 sig_3 sig_4 sig_5 sig_6 sig_7 sig_8 sig_9 sig_10];
%% Preprocessing
selection = multichannel(20000:21000,:);
sel1 = multichannel(40000:41000,:);
sel2 = multichannel(20000:21000,:);
%% Přepočet na RMS
selection_rms = calc_rms2(selection);
theta = -pi/2:(pi/2)/9:0;
%% Polarplot
selection_db = calc_db(calib,selection_rms,true);
figure
polarplot(theta,selection_db);
hold off
X1 = fft(sel1(:,1));
X2 = fft(sel2(:,1));
X1 = X1(1:round(length(X1)/2));
X2 = X2(1:round(length(X2)/2));
figure
plot(abs(X1))
hold on
plot(abs(X2))