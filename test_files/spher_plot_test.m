len = length(load("../MERENI 360 po 5/meas1_main_test_n_0.mat").signal);
Fs = 48000;
band = 30;
fontsz = 20;
close all
x = audioread("measurement_tones/sweep_1s_48000.wav");
conf = load('../MERENI 360 po 5/konfigurace/meas_config.mat');
y = zeros(conf.nmeas,len,conf.nchan);
for meas = 1:conf.nmeas
y(meas,:,:) = load(strcat("../MERENI 360 po 5/meas1_main_test_n_",num2str(meas-1), ".mat")).signal;
end
x = [x; zeros(len-length(x),1)];
freqs = linspace(-Fs/2,Fs/2,len);
Y = zeros(conf.nmeas,len,conf.nchan);
for meas = 1:conf.nmeas
    Y(meas,:,:) = fftshift(fft(y(meas,:,:)));
end

X = fftshift(fft(x));
X(abs(X)<30) = 30;
H = zeros(conf.nmeas,len/2, conf.nchan);
for meas = 1:conf.nmeas
    for mic = 1:conf.nchan
        H(meas,:,mic) = Y(meas,len/2+1:end,mic)./X(len/2+1:end)';
        
    end
end
rms_vals = zeros(conf.nmeas, conf.nchan);
db_vals = zeros(conf.nmeas+1, conf.nchan);
[fc,fu,fl]=fract_bands();
inds= f_to_ind(freqs(len/2+1:end),fl(band),fu(band));
for meas = 1:conf.nmeas
    for mic = 1:conf.nchan
        rms_vals(meas,mic) = calc_rms2(abs(H(meas,inds,mic)));
        db_vals(meas,mic) = calc_db(conf.calib(mic),rms_vals(meas,mic),true);
    end
end
for mic = 1:conf.nchan
    db_vals(conf.nmeas+1,mic) = db_vals(1,mic) ;
end

me_leg_lbls = {[]};
m_leg_lbls = {[]};

M = 2;%scale factor
offset = 40;
%db_vals = db_vals - (min(min(db_vals))-40);
phi = linspace(min(conf.anlis.angles), max(conf.anlis.angles),conf.nmeas+1);
theta = linspace((min(conf.micta.elevation)-offset)*2, (max(conf.micta.elevation)-offset)*2,conf.nchan);

phi = deg2rad(phi);
theta = deg2rad(theta);
%% polar plot dle mereni
figure
for meas = 1:10
    polarplot(theta,db_vals(meas,:),LineWidth=1.5);
    me_leg_lbls(meas)={['Měření č.',num2str(meas),', ',num2str(conf.anlis.angles(meas)),'°']};
    hold on
end
pol_ax = gca;
r_ax = pol_ax.RAxis;
r_ax.Label.String = "P dB(SPL)";
pol_ax.RLim = [60 110];
pol_ax.ThetaZeroLocation = 'right';
pol_ax.ThetaLim = [-90 90];
pol_ax.ThetaTick = -90:10:90;
title(['Vertikální 2D směrová char. v pásmu č. ',num2str(band),', f_c = ',num2str(round(fc(band))),' Hz'])
legend(me_leg_lbls,"Location","northwest");
fontsize(fontsz,"points");
hold off

%% polar plot dle micu ----------------------------------------
figure
for mic = 1:7
    polarplot(phi,db_vals(:,mic),LineWidth=1.5);
    hold on
    m_leg_lbls(mic)={['Mikrofon č.',num2str(mic)]};
end
pol_ax = gca;
r_ax = pol_ax.RAxis;
r_ax.Label.String = "P dB(SPL)";
pol_ax.RLim = [60 110];
pol_ax.ThetaZeroLocation = "right";
pol_ax.ThetaTick = 0:15:360;
fontsize(fontsz,"points");
title(['Horizontální 2D směrová char. v pásmu č. ',num2str(band),', f_c = ',num2str(round(fc(band))),' Hz'])
legend(m_leg_lbls,"Location","northeast");
hold off


%% KONEC-----------------------------

phi_i = linspace(min(conf.anlis.angles), max(conf.anlis.angles),(conf.nmeas+1)*M-1);
theta_i = linspace(min(conf.micta.elevation)-offset, max(conf.micta.elevation)-offset,conf.nchan*M-1);

phi_i = deg2rad(phi_i);
theta_i = deg2rad(theta_i);


%% SFÉRICKÝ GRAF ----------------------------------------
figure
[phi2D,theta2D] = meshgrid(phi_i,theta_i);
db_vals_i = interp2(db_vals',1);
[x,y,z]=sph2cart(phi2D,theta2D,db_vals_i-60);
mesh(x,y,z,EdgeColor='k',FaceColor="interp");
title(['Směrová char. v pásmu č. ',num2str(band),', f_c = ',num2str(round(fc(band))),' Hz'])
pbaspect([1 1 1])
view([90 45])
fontsize(fontsz,"points");
% 
% 
% for meas = 1:conf.nmeas
% 
% end
figure
draw_fr_oct(squeeze(abs(H(1,:,4))), freqs(len/2+1:end), conf.calib(4))

figure
draw_spect(squeeze(abs(H(1,:,4))), freqs(len/2+1:end), conf.calib(4))
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
        inds = f_to_ind(freqs,lf(i),uf(i));
        rms_vals(i) = calc_rms2(sig(inds));
    end
    db_vals = calc_db(calib,rms_vals,true);
    bar(1:length(cf),db_vals)
    title("Třetinooktávová analýza v akustické ose");
    xticks(1:length(cf))
    xticklabels(round(cf))
    xlabel('f [Hz] \rightarrow')
    ylabel('P [dB(SPL)] \rightarrow')
    ylim([50 110])
    axis normal
    fontsize(16,"points");
end

function draw_spect(sig, freqs, calib)
    leg_lbls = {[]};
    for mic = 1:length(calib)
        db_vals = calc_db(calib,squeeze(sig)',true);
        leg_lbls(mic) = {[num2str(mic),'. mikrofon, úhel odklonu ',num2str(-60+((mic-1)*20)),' °']};
    end
    
    semilogx(freqs,db_vals,LineWidth=1.5)
    title("Modulově kmitočtové spektrum v akustické ose");
    grid on
    xlabel('f [Hz] \rightarrow')
    ylabel('P [dB(SPL)] \rightarrow')
    yticks(50:5:110)
    core = [2 3 5 10];
    xticks([core.*10 core.*100 core.*1000 20000])
    xlim([20 20E3])
    ylim([50 110])
    %legend(leg_lbls)
    fontsize(20,"points")
end