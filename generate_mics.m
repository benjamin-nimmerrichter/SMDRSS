clearvars
num_mics = 10;
mic_number = 1:num_mics; % generate vector
elevation = zeros(1,num_mics);
channel_mapping = mic_number;
T = table(mic_number,elevation,channel_mapping);
T