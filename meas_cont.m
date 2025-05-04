function [meas_out,out_ind] = meas_cont(Fs,mics,buffsz,aPR,threshold,meas_per)
%MEAS_CONT Summary of this function goes here
%   Detailed explanation goes here


bufferAmt = (ceil(Fs/buffsz))*meas_per; % amount of buffers needed

%n = linspace (0,round(fs*beepT),round(fs*beepT)); % number of samples for beep
%t = n./fs; % time vector (just for the test plot)
%beep = sin(2*pi*f*t); % vector of harmonic beep "recording started"
%plot(t,beep)

%% CYCLIC BUFFER 5s(10s)
% buffer initialization
inBuffer = zeros(buffsz,2); 
mainBuffer = zeros(mics,bufferAmt,buffsz);
meas_out = zeros(mics,buffsz*bufferAmt);

% variable initialization
running = true;
active = false;
detect_stop = false;
lst_a = active;
hyst = 0;
currentind = 1;


while running == true

    % record buffers 
    % record and play
    outBuffer = aPR(inBuffer);
    
    % analyse RMS values
    %rms_vals = calc_rms2(outBuffer);
    %temp1 = max(rms_vals);
    %max_rms = max(temp1);
    
    % detect peaks
    temp2 = max(outBuffer);
    max_peak = abs(max(temp2));
    
    % add samples to main circular buffer
    for chan = 1:mics
        mainBuffer(chan,currentind,:) = outBuffer(:,chan);
    end

    % FSM control
    if max_peak >= threshold
        hyst = 0;
        active = true;
        str = ["Active" num2str(max_peak)];
        disp(str)
    else
        hyst = hyst + 1;
        if hyst > 5 % hysteresis
            active = false;
            %running = false;
        end
    end

    if active
        if lst_a ~= active % state switch detection
            start_ind = currentind-1; % prerecording
            if start_ind == 0 % wraparound
                start_ind = bufferAmt;
            end
            stop_ind = start_ind-1; % records whole buffer
            if stop_ind == 0 %wraparound
                stop_ind = bufferAmt;
            end
        end
    end
    if lst_a ~= active 
        if active == true
            detect_stop = true;
        else
            out_ind = currentind; 
            % if state changes to inactive, save out index
        end
    end
    if detect_stop
        if currentind == stop_ind % when buffer is full
            active = false;
            running = false;
        end
    end
    
    % holds last value of active
    lst_a = active;

    % index incrementation and looping
    currentind = currentind + 1;
    if currentind > bufferAmt
        currentind = 1;
    end
end

    for chan = 1:mics
        temp = mainBuffer(chan,:,:);
        temp = reshape(temp,bufferAmt,buffsz);
        temp = circshift(temp,-(start_ind-1),1); % unwrap circular buffer WIP
        meas_out(chan,:) =  reshape(temp',1,[]);
    end   
    % transpose matrix to expected form
    meas_out = meas_out'; 
    return
end

