clearvars
close all
%% TIME DOMAIN PLOT
S = data_ingest;
S_mics = S.mic;
S_points = S.mic.point;

passes = length(S);
mics = length(S_mics);
points = length(S_points);
sig_len = length(S(1).mic(1).point(1).sig);
Fs = S.dev.fs;
t = (1:sig_len)./Fs;

% init
signal = zeros(passes,mics,points,sig_len);

for pass = 1:passes
    for mic = 1:mics
        for point = 1:points
            signal(pass,mic,point,:) = S(pass).mic(mic).point(point).sig;
        end
    end
end

f = figure;
f.Position = [100 100 800 500];

for point = 1:points
signal_1d = reshape(signal(1,1,point,:),1,[]);
plot(t,signal_1d,LineWidth=1)
energy(point) = sum(signal_1d.^2);
s = strcat("Měření č.", num2str(point),", energie = ",num2str(energy(point)));
labels(point) = s;
hold on
end
fontsize(15,"points")
title("Porovnání detekce spuštění vyrovnávací paměť 1024 vzorků")
xlabel("Čas (s) \rightarrow")
ylabel("Hodnota signálu (-) \rightarrow")
legend(labels)
