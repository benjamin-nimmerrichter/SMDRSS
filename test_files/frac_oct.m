%% CLEANUP
close all
clearvars
%% INPUT VALS
% --- select fr-oct bands to analyze
Npass = 6;
Nmic = 1;
Npoint = 32;

max_b = 20;
min_b = 15;

db_step = 6;
deg_step = 20;

titl = "Click to change title";
fontSz = 15;
lineW = 1;
%% SCRIPT
S = data_ingest;
q = S.mic;
k = S(1).mic.point;
n_passes = length(S);
n_mics = length(q);
n_points = length(k);
total_len = n_passes*n_mics*n_points;
calib = zeros(n_mics,1);
split = true;
for mic = 1:n_mics
    calib(mic) = S(1).mic(mic).calib;
end
[x,Fs] = audioread("measurement_tones\sweep_1s_48000.wav");
temp = S(1).mic.point(1).sig;
len = length(temp);

signals = zeros(len, 1);
Y = zeros(len,1);

freqs = linspace(-Fs/2,Fs/2,len);
x = [x; zeros(len-length(x),1)];

X = fftshift(fft(x))';
X(abs(X)<30) = 30;

for pass = 1:n_passes
    for mic = 1:n_mics
        for point = 1:n_points            
            signal = S(pass).mic(mic).point(point).sig;
            Y = fftshift(fft(signal));
            H.pass(pass).mic(mic).point(point).tf = Y./X;
        end
    end
end

f = figure;
f.Position = [100 100 800 500];
H_nibble = H.pass(Npass).mic(Nmic).point(Npoint).tf;
sig = abs(H_nibble((len/2)+1:end));
draw_fr_oct(sig, freqs((len/2)+1:end), calib, fontSz);

%% FUNCTIONS ----------------------------------------

function draw_fr_oct(sig, freqs, calib,fontSz)
    [cf, uf, lf] = fract_bands();
    rms_vals = zeros(length(cf),1);
    for i = 1:length(cf)
        inds = f_to_ind(freqs,lf(i),uf(i));
        rms_vals(i) = 2.*calc_rms2(sig(inds));
    end
    db_vals = calc_db(calib,rms_vals,true);
    bar(1:length(cf),db_vals)
    title("Třetinooktávová analýza v akustické ose");
    xticks(1:length(cf))
    xticklabels(round(cf))
    xlabel('f (Hz) \rightarrow')
    ylabel('L_p dB(SPL) \rightarrow')
    ylim([40 110])
    fontsize(fontSz,"points")
    axis normal
end