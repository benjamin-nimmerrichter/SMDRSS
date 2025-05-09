function T = gen_mic_table(num_mics,num_passes,start_channel)
%GEN_MIC_TABLE generate table for mic editting
%   Used for SMDRSS ap by Benjamin Nimmerrichter 2024

% amount of lines in the table
num_lines = num_passes*num_mics;
empty_lines = zeros(num_lines,1);
pass_number = empty_lines;
mic_number  = empty_lines; 
azimuth     = empty_lines;
elevation   = empty_lines;

for pass = 1:num_passes
    for mic = 1:num_mics
        ind = mic + (pass-1)*num_mics;
        mic_number(ind) = mic;
        pass_number(ind) = pass;
    end
end

channel_mapping = mic_number+(start_channel-1);
T = table(pass_number,mic_number,azimuth,elevation,channel_mapping);
end