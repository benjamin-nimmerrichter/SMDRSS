function out = calc_rms2(data)
%CALC_RMS2 calculate RMS value of signal  
    t_sum=(sum(data.^2)); % sum of roots
    t_mean =t_sum/length(data); % mean (1/N)*t_sum    
    out=sqrt(t_mean); %sqare the mean, output RMS value