%% POLAR PLOT TEST
%band = 25;

close all

conf = load("Měření 14-11\meas_config_mic_na_rameni.mat");
[x,Fs] = audioread("measurement_tones\sweep_1s_48000.wav");
temp = load("Měření 14-11\90 stupnu\meas1_main_test_n_9_onax.mat").signal;
len = length(temp);
signals = zeros(len,10);
signals(:,10) = temp;

phi = (-90:10:90)*pi/180;

for meas = 1:9
    signals(:,meas) = load(strcat("Měření 14-11\90 stupnu\meas1_main_test_n_",num2str(8-(meas-1)) ,".mat")).signal;
end
freqs = linspace(-Fs/2,Fs/2,len);
x = [x; zeros(len-length(x),1)];

Y = fftshift(fft(signals));
X = fftshift(fft(x));
X(abs(X)<30) = 30;
H = zeros(len,10);
leg_lbls = {[]};
split = true;
if split
    for meas = 2:2:10
        H(:,round(meas/2)) = Y(:,meas)./X;
        
        leg_lbls(round(meas/2)) ={[num2str(meas),'. měření, úhel odklonu ',num2str(10*(9-(meas-1))),'°']};
    end
else
    for meas = 1:10
        H(:,round(meas)) = Y(:,meas)./X;
        
        leg_lbls(round(meas)) ={[num2str(meas),'. měření, úhel odklonu ',num2str(10*(9-(meas-1))),'°']};
    end
end
%conf.calib
% figure
% semilogx(freqs((len/2)+1:end),abs(X((len/2)+1:end)));
% xlim([20 20E3]);
% figure
% semilogx(freqs((len/2)+1:end),abs(Y((len/2)+1:end,:)));
% xlim([20 20E3]);
%% FREQUENCY RESPONSE
figure
semilogx(freqs((len/2)+1:end), ...
    calc_db(conf.calib,abs(H((len/2)+1:end,:)),true), ...
    LineWidth=1);
grid on
xlabel('f [Hz] \rightarrow')
ylabel('P [dB(SPL)] \rightarrow')
yticks(50:5:110)
core = [2 3 5 10];
xticks([core.*10 core.*100 core.*1000 20000])
title("Přenosová funkce reproduktoru v závislosti na úhlu odklonu od akustické osy")
xlim([20 20E3])
ylim([50 110])

legend(leg_lbls,Location="south");
hold off
%% IMPULSE RESPONSE
times = linspace(1/Fs,1/Fs*len,len);
figure
h = ifft(H);
subplot 211
plot(times,real(h),LineWidth=1.5);
xlabel('t [s] \rightarrow')
ylabel('hodnota signálu [-] \rightarrow')
fontsize(20,"points")
grid on
%yticks(50:5:110)
%core = [2 3 5 10];
xticks(0.085:0.002:0.105)
title("Impulzní odezva reproduktoru v závislosti na úhlu odklonu od akustické osy")
xlim([0.085 0.105])
%ylim([50 110])

legend(leg_lbls,Location="northeast");
hold off
subplot 212
plot(times,abs(h),LineWidth=1.5);
xticks(0.085:0.002:0.105)
title("Impulzní odezva reproduktoru v absolutní hodnotě")
xlim([0.085 0.105])
fontsize(20,"points")
xlabel('t [s] \rightarrow')
ylabel('hodnota signálu [-] \rightarrow')
grid on

%% FRACTIONAL OCTAVE BANDS
figure
if split
    indx = 5;
else
    indx = 10;
end
sig = abs(H((len/2)+1:end,indx));
draw_fr_oct(sig, freqs((len/2)+1:end), conf.calib);
%% DIRECTIONAL CHAR
if ~split
figure
[fc,fu,fl] = fract_bands();
fr = freqs((len/2)+1:end);
phi_i = interp(phi,2);
phi_ii = interp(phi_i,2);
min_val = 200;
max_val = 0;
leg_lbls = {[]};
max_b = 30;
min_b = 25;
for band = min_b:max_b
ind = f_to_ind(freqs,fl(band),fu(band));

rms_values = calc_rms2(abs(H(ind,:)));
db_values = calc_db(conf.calib,rms_values,true);
db_f = flip(db_values,2);
db_values = [db_values, db_f(2:end)];
min_val = min(min_val,min(db_values));
max_val = max(max_val,max(db_values));
db_i  = interp(db_values,2);
db_ii  = interp(db_i,2);
polarplot(phi_ii,db_ii,LineWidth=1)
leg_lbls(band-(min_b-1))={['b = ',num2str(band),', cf = ',num2str(round(fc(band))), ' Hz']};
hold on
end
pol_ax = gca;
pol_ax.ThetaZeroLocation = 'top';
pol_ax.RLim = [min_val-3 max_val+3];
pol_ax.ThetaLim = [-90 90];
pol_ax.ThetaTick = -90:5:90;
pol_ax.RTick=round(min_val-3):3:round(max_val+3);
r_ax = pol_ax.RAxis;
r_ax.Label.String = "P dB(SPL)";

title("Směrová vyzařovací charakteristika reproduktoru")
legend(leg_lbls,"Location","northeast");
end

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
    ylim([40 110])
    axis normal
end