%% CLEANUP
close all
clearvars
%% INPUT VALS
% --- select fr-oct bands to analyze
Npass = 1;
Nmic = 1;
Npoint = [1 37];

max_b = 20;
min_b = 15;

db_step = 6;
deg_step = 20;

titl = "Click to change title";
fontSz = 15;
lineW = 1;

long_leg = false;
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
times = linspace(1/Fs,1/Fs*len,len);
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
N = 1;
f = figure;
f.Position = [100 100 800 500];
for pass = 1:numel(Npass)
    for mic = 1:numel(Nmic)
        for point = 1:numel(Npoint)
            pass_n = Npass(pass);
            mic_n = Nmic(mic);
            point_n = Npoint(point);
            H_nibble = H.pass(pass_n).mic(mic_n).point(point_n).tf;
            
            h = len*ifft(H_nibble);
            plot(times,real(h),"LineWidth",lineW);
            az = S(pass_n).mic(mic_n).point(point_n).az;
            el = S(pass_n).mic(mic_n).point(point_n).el;
            if long_leg
                s = strcat(" pass:", num2str(pass_n), ...
                    " mic: ",num2str(mic_n), ...
                    " point: ", num2str(point_n), ...
                    " az.: ", num2str(az),...
                    " el.: ", num2str(el));
            else
                s = strcat(" azim.: ", num2str(az),...
                    "° elev.: ", num2str(el),"°"); 
            end
            leg_lbls(N) = s;
            hold on
            N = N+1;
        end
    end
end
grid on
xlabel('t [s] \rightarrow')
ylabel('hodnota signálu [-] \rightarrow')
title(titl)
legend(leg_lbls)
fontsize(fontSz,"points");



%% FUNCTIONS ----------------------------------------
function index_arr = f_to_ind(freqs,fmin, fmax)
    for i=1:length(freqs)
        if (freqs(i) <= fmin)
            min_ind = i;
        end
        if (freqs(i) >= fmax)
            max_ind = i;
            break;
        end
    end
    index_arr = (min_ind:max_ind);
end

function [fc,fu,fl] = fract_bands()
    fc = 10.^(0.1.*(12:43));
    fd = 10^0.05;
    fu = fc*fd;
    fl = fc/fd;
end
