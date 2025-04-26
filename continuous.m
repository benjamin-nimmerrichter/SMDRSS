%% --- Continuous measurement for acoustic sound sources.
% ** not needed for script version

headroomDB = 6;
numclips = 20;
aPR = audioPlayerRecorder; % create audio player recorder object
fs = 44100; % sample rate of the recording
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
inBuffer = zeros(bufferSz,1);
outBuffer = zeros(bufferSz,1); 
mainBuffer = zeros(bufferAmt,bufferSz);
recording = true;
inind = 0;
currentind = 1;
outind = 0;
STOPind = 0;
while recording == true
    % record buffers 
    % record and play
    outBuffer = aPR(inBuffer);

    % add samples to main circular buffer
    mainBuffer(currentind,:) = outBuffer(:,:);
    currentind = currentind + 1;
    if currentind > bufferAmt
        currentind = 1;
    end

    for mic = 1:mics
        rms_vals(mics) = calc_rms2(outBuffer);
        % if RMS rises, do prerecording step
        max_rms = max(rms_vals);
        max_rms = max(max_rms);
        if started == false
            if max_rms > threshold
                started = true;
                inind = currentind-1;
                if inind < 1
                    inind = bufferAmt;
                end
                STOPind = mod(inind + bufferAmt-1, bufferAmt)+1;
            end
        end
    end
    
    % if RMS falls, do postrecording step
    if started == true
        if currentind ~= STOPind
            if currentind > inind + minbufferAmt
                if max_rms < threshold
                    outind = currentind;
                    recording = false;
                end
            end
        else
            outind = STOPind;
            recording = false;
        end
    end
    % if prerecording and postrecording is done (and for long enough), end
    if inind && outind
    end
end
meas_out = reshape(mainBuffer(inind:outind,:),1,[]);

% TODO: Multi channel
% TODO: Clip detect