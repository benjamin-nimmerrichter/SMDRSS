%% CLEANUP
close all
clearvars
%% INPUT VALS
% --- select fr-oct bands to analyze

max_b = 19;
min_b = 19;

db_step = 6;
deg_step = 20;

titl = "Click to change title";
fontSz = 20;
lineW = 1;

%% IMPORTANT
%TODO : switch for TF processing
%% PREPROCESSING
S = data_ingest;
q = S.mic;
k = S(1).mic.point;
n_passes = length(S);
n_mics = length(q);
n_points = length(k);
total_len = n_passes*n_mics*n_points;
calib = zeros(n_mics,1);
split = true;
%leg_lbls = {[]};

[x,Fs] = audioread("measurement_tones\sweep_1s_48000.wav");
temp = S(1).mic(1).point(1).sig;
len = length(temp);

signals = zeros(len, 1);
Y = zeros(len,1);

freqs = linspace(-Fs/2,Fs/2,len);
x = [x; zeros(len-length(x),1)];

X = fftshift(fft(x))';
X(abs(X)<30) = 30;
%% LOAD VALUES AN CALCULATE TF
for mic = 1:n_mics
    calib(mic) = S(n_passes).mic(mic).calib;
end

for pass = 1:n_passes
    for mic = 1:n_mics
        for point = 1:n_points            
            signal = S(pass).mic(mic).point(point).sig;
            Y = fftshift(fft(signal));
            H.pass(pass).mic(mic).point(point).tf = Y./X;
        end
    end
end

%% DIRECTIONAL CHAR DRAW OUTPUT
figure

[fc,fu,fl] = fract_bands();
fr = freqs((len/2)+1:end);
min_db = 200;
max_db = 0;

number = 1;
phi = zeros(n_points,1);
db_values = zeros(n_points,1);
N = 1;
for band = min_b:max_b
    ind = f_to_ind(freqs,fl(band),fu(band));
    for mic = 1:n_mics
        for point = 1:n_points
            H_nibble = H.pass(n_passes).mic(mic).point(point).tf;
            rms_val = calc_rms2(abs(H_nibble(ind)));
            rms_val(rms_val <= 0) = 1E-10;
            % rho
            db_values(point) = calc_db(calib(mic),rms_val,true);
            % phi
            phi(point) = deg2rad(S(number).mic(mic).point(point).az);
        end
    end

    polarplot(phi,db_values,LineWidth=lineW)
    s = strcat("f = ",num2str(round(fc(band))), " Hz");
    leg_lbls(N) = s;
    hold on

    min_db = min(db_values,min_db);
    max_db = max(db_values,max_db);
    N = N+1;
end

% ---- styling ----
min_db = round(min(min_db));
max_db = round(max(max_db));
pol_ax = gca;
pol_ax.ThetaZeroLocation = 'top';
pol_ax.RLim = [min_db-3 max_db+3];
%pol_ax.ThetaLim = [min_db-3 max_db+3];
pol_ax.ThetaTick = 0:deg_step:360;
pol_ax.ThetaMinorTick = "on";
pol_ax.RTick=min_db:db_step:max_db;
r_ax = pol_ax.RAxis;
r_ax.Label.String = "P dB(SPL)";

fontsize(fontSz,"points");

title(titl)
legend(leg_lbls,"Location","northeast");

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