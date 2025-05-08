%% --- Continuous measurement for acoustic sound sources.
% ** not needed for script version

clear all
headroomDB = 6;
numclips = 20;
channelMap = [1,2,3,4];
channelCount = length(channelMap);
fs = 44100; % sample rate of the recording
aPR = audioPlayerRecorder(fs,RecorderChannelMapping=channelMap); % create audio player recorder object
f = 500; % beep frequency
bufferSz = 1024; % samples
bufferT = 5; % seconds
minT = 0.1; % min recording time seconds
beepT = 0.2; % seconds
threshold = 0.01; % threshold to start recording
mics = 1;

% ** not needed for script version

bufferAmt = (ceil(fs/bufferSz))*bufferT; % amount of buffers needed
minbufferAmt = (ceil(fs/bufferSz))*minT; % minimum amout of buffers to be a recording
n = linspace (0,round(fs*beepT),round(fs*beepT)); % number of samples for beep
t = n./fs; % time vector (just for the test plot)
beep = sin(2*pi*f*t); % vector of harmonic beep "recording started"
%plot(t,beep)
started = false; % if the recording got triggered

%% CYCLIC BUFFER 5s(10s)
% initialization
inBuffer = zeros(bufferSz,1);
outBuffer = zeros(bufferSz,channelCount); 
mainBuffer = zeros(channelCount,bufferAmt,bufferSz);
meas_out = zeros(channelCount,bufferSz*bufferAmt);
% initialization
running = true;
active = false;
detect_stop = false;
lst_a = active;
hyst = 0;
currentind = 1;
clipped = false;

while running == true

    % record buffers 
    % record and play
    outBuffer = aPR(inBuffer);
    
    % analyse RMS values
    rms_vals = calc_rms2(outBuffer);
    temp1 = max(rms_vals);
    max_rms = max(temp1);

    temp2 = max(outBuffer);
    max_peak = abs(max(temp2));
    % add samples to main circular buffer
    for chan = 1:channelCount
        mainBuffer(chan,currentind,:) = outBuffer(:,chan);
    end

    % FSM control
    if max_peak >= threshold
        hyst = 0;
        active = true;
        disp("Active")
    else
        hyst = hyst + 1;
        if hyst > 5 % hysteresis
            active = false;
            %running = false;
            clipped = false;
            disp("Standby")
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

    lst_a = active;% holds last value of active
    % index incrementation and looping
    currentind = currentind + 1;
    if currentind > bufferAmt
        currentind = 1;
    end
end

for chan = 1:channelCount
    temp = mainBuffer(chan,:,:);
    temp = reshape(temp,bufferAmt,bufferSz);
    temp = circshift(temp,-(start_ind-1),1); % unwrap circular buffer WIP
    meas_out(chan,:) =  reshape(temp',1,[]);
end    


plot(meas_out(1,:))
hold on
plot(meas_out(2,:))
plot(meas_out(3,:))
plot(meas_out(4,:))
% TODO: Multi channel
% TODO: When activated nothing happens????