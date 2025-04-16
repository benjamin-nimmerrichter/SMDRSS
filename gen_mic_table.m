function T = gen_mic_table(num_mics)
%GEN_MIC_TABLE generate table for mic editting
%   Used for SMDRSS ap by Benjamin Nimmerrichter 2024
    mic_number = (1:num_mics)'; % generate vector
    azimuth = zeros(1,num_mics)';
    elevation = azimuth;
    channel_mapping = mic_number;
    T = table(mic_number,azimuth,elevation,channel_mapping);
end