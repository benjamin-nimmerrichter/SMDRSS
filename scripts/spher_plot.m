%% CLEANUP
close all
clearvars
[fc,fu,fl] = fract_bands();
%% INPUT VALS
% --- select fr-oct bands to analyze

band = 12;
%db_offset = 40;

db_step = 6;
deg_step = 20;

titl = "Spherical plot";
ext_titl = strcat(titl," at ",num2str(round(fc(band)))," Hz ");
fontSz = 14;
lineW = 1;

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

[x,Fs] = audioread("measurement_tones\sweep_1s_48000.wav");
temp = S(1).mic.point(1).sig;
len = length(temp);

signals = zeros(len, 1);
Y = zeros(len,1);

freqs = linspace(-Fs/2,Fs/2,len);
x = [x; zeros(len-length(x),1)];

X = fftshift(fft(x))';
X(abs(X)<30) = 30;
%% LOAD VALUES AN CALCULATE TF
for pass = 1:n_passes
    for mic = 1:n_mics
        calib(pass,mic) = S(pass).mic(mic).calib;
    end
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


fr = freqs((len/2)+1:end);
min_db = 200;
max_db = 0;

number = 1;
phi = zeros(n_points,1);
theta = zeros(n_passes,1);
db_values = zeros(n_passes,n_points);


ind = f_to_ind(freqs,fl(band),fu(band));
s = strcat("f = ",num2str(round(fc(band))), " Hz");
%% PROCESS
for pass = 1:n_passes
    for mic = 1:n_mics
        for point = 1:n_points
            H_nibble = H.pass(pass).mic(mic).point(point).tf;
            rms_val = calc_rms2(abs(H_nibble(ind)));
            rms_val(rms_val <= 0) = 1E-10;
            %rho
            db_values(pass,point) = calc_db(calib(pass, mic),rms_val,true);
            %phi
            phi(point) = deg2rad(S(pass).mic(mic).point(point).az);            
            %theta
            theta(pass) = deg2rad(S(pass).mic(mic).point(point).el);
            % legend label

        end
    end
end

%% PLOT
[Phi,Theta] = meshgrid(phi,theta);
%surf(db_values)
db_offset = min(min(db_values))-3;
[x,y,z] = sph2cart(Phi,Theta,db_values-db_offset);

% figure
% surf(x,y,z)
% view([90 45])
% pbaspect([1 1 1])
% fontsize(fontSz,"points");
% title(titl)
% set(gca,'xticklabel',[])
% set(gca,'yticklabel',[])
% set(gca,'zticklabel',[])

figure
surf(x,y,z)
hold on 
scatter(50,0,150,"k x","LineWidth",lineW*2)
%k1 = 1:2:20;
%scatter(k1,0,"k |","LineWidth",lineW)
view([90 0])
pbaspect([1 1 1])
fontsize(fontSz,"points");
title(ext_titl)
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
set(gca,'zticklabel',[])

figure
surf(x,y,z)
hold on
scatter(0,0,150,"k x","LineWidth",lineW*2)
k1 = 2:2:18;
scatter(k1,0,"k |","LineWidth",lineW)
view([-90 90])
pbaspect([1 1 1])
fontsize(fontSz,"points");
title(ext_titl)
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
set(gca,'zticklabel',[])
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