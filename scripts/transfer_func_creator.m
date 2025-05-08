clear all
close all
Fs = 48000;
x = audioread("../measurement_tones/sweep_1s_48000.wav");
conf = load('../MERENI 360 po 5/konfigurace/meas_config.mat');
y = zeros(conf.nmeas,length(load("../MERENI 360 po 5/meas1_main_test_n_0.mat").signal),conf.nchan);
for meas = 1:conf.nmeas
y(meas,:,:) = load(strcat("../MERENI 360 po 5/meas1_main_test_n_",num2str(meas-1), ".mat")).signal;
end
x = [x; zeros(length(y(1,:,1))-length(x),1)];

x = x';

Y = fftshift(fft(y));
X = fftshift(fft(x));

len = length(x);
chans = size(y,3);

freqs = linspace(0,Fs/2,ceil(len/2)+1);
times = 1./freqs;
tfunc = zeros(conf.nmeas,len,chans);
X(abs(X)<20) = 20;

for meas = 1:conf.nmeas
    for chan = 1:chans
        tfunc(meas,:,chan) = (Y(meas,:,chan)./X);
    end
end
modX = abs(X);
modX = modX(len/2:len);

modY = abs(Y);
modY = modY(:,len/2:len,:);

modtfunc = abs(tfunc);
modtfunc = modtfunc(:,len/2:len,:);

tf_rms = zeros(meas,chans);
tf_DB = zeros(meas,chans);
% RMS RMS
for meas = 1:conf.nmeas
    for chan = 1:chans
        tf_rms(meas,chan) = calc_rms2(modtfunc(meas,:,chan));
    end
end

for meas = 1:length(conf.nmeas)
    for chan = 1:chans
        tf_DB(meas,chan) = calc_db(conf.calib(chan),tf_rms(meas,chan),true);
    end
end
figure
plot(freqs,modY(1,:,1))
figure
temp(:,:) = modtfunc(1,:,:);
semilogx(freqs,temp)
figure
indices = f_to_ind(freqs,250,315);
calc_db(conf.calib',calc_rms2(modtfunc(1,indices,:)),true)
grid on
xlabel("Frequency (Hz)")
xlim([20 20000])
ylabel("Sound pressure level (dB_S_P_L)")
legend("Mic 1 -30 deg","Mic 2 -20 deg","Mic 3 -10 deg","Mic 4 0 deg","Mic 5 10 deg","Mic 6 20 deg","Mic 7 30 deg","Location","southwest")
xlabel("Frequency (Hz)")
xlim([20 20000])
ylabel("Sound pressure level (dB_S_P_L)")
figure
temp(:,:) = tfunc(1,len/2:len,:);
plot(freqs,unwrap(angle(temp)));
grid on
figure
plot(real(ifft(temp)));
grid on
figure
%draw_fr_oct(modtfunc(:,1),freqs,conf.calib)
fr_oct_sb(modtfunc, freqs, conf, 9)

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

function draw_fr_oct(sig, freqs, calib)
    [cf, uf, lf] = fract_bands();
    rms_vals = zeros(length(cf),1);
    for i = 1:length(cf)
    rms_vals(i) = calc_rms2(sig((f_to_ind(freqs,lf(i),uf(i))))); 
    end
    db_vals = calc_db(calib(1),rms_vals,true);
    bar(1:length(cf),db_vals)
    xticks(1:length(cf))
    xticklabels(round(cf))
    axis normal
end

function fr_oct_sb(tfuncs, freqs, conf, band)
    % tfuncs dimensions (coefficients, mic, measurement)
    [cf, uf, lf] = fract_bands();
    inds = f_to_ind(freqs,lf(band),uf(band));
    disp(inds)
    db_vals = zeros(conf.nmeas,conf.nchan);
    for meas = 1:conf.nmeas
        rms_vals = squeeze(calc_rms2(tfuncs(meas,inds,:)));
        disp(rms_vals)
        db = calc_db(conf.calib,rms_vals,true);
        db_vals(meas,:) = db;
    end

    phi = conf.anlis.angles(1:(end-1)).*(pi/180);
    theta = (conf.micta.elevation).*(pi/180);
    %disp(strcat("phi",num2str(phi),"theta",num2str(theta)));

    [phi,theta] = meshgrid(phi,theta);

    disp(db_vals)
    
    % phi = interp2(phi,5);
    % theta = interp2(theta,5);
    % db_vals = interp2(db_vals,5);
    [x,y,z]=sph2cart(phi,theta,db_vals');
    mesh(x,y,z,EdgeColor="none",FaceColor="interp");
    pbaspect([1 1 1])
end