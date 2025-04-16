% x = [-2 0.6 1.2 1.5 1.83 2];
% y = [2 -2 0 -1.5 -1.83 -2];
% [X,Y] = meshgrid(x,y);
% Z = ones(length(x),length(y));
% surf(X,Y,Z);
%data = struktura
%% INIT STRUCTURE
mic_amt = 5;    % amount of mics
meas_amt = 20;  % amount of measurements (at first)
len = 5000;     % length of measurement in samples


% config - configuration structure
% meas - measurement structure

for pnt = 1:meas_amt
    for mic = 1:mic_amt
        if pnt == 1 % mic config data
            config.mic(mic).calib = 0;
            config.mic(mic).SNR = 0;
           
        end

        meas.point(pnt).mic(mic).pos_az = 0; %azimuth
        meas.point(pnt).mic(mic).pos_el = 0; %ekevation
        meas.point(pnt).mic(mic).signal = zeros(len,1); %signal
    end
end
name = "test3";
save_config(config,name)
save_meas(meas,name)
%clearvars("data")

%data.config = readstruct("test_file.xml","FileType","xml");
%data.config

