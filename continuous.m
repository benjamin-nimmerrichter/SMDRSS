aPR = audioPlayerRecorder;
fs = 44100;
f = 1000;
bufferSz = 1024; % samples
bufferT = 5; % seconds
minT = 0.1; % min recording time seconds
beepT = 0.2; % seconds
threshold = 0.1; % threshold to start recording
bufferAmt = (ceil(fs/bufferSz))*bufferT;
minbufferAmt = (ceil(fs/bufferSz))*minT;
n = linspace (0,round(fs*beepT),round(fs*beepT));
t = n./fs;
beep = sin(2*pi*f*t);
%plot(t,beep)

%% CYCLIC BUFFER 5s(10s)
inBuffer = zeros(bufferSz);
outBuffer = zeros(bufferSz); 
mainBuffer = zeros(bufferAmt,bufferSz);
recording = true;
inind = -1;
currentind = 1;
outind = -1;
STOPind = -1;
while recording == true
% record buffers 

outBuffer = aPR(inBuffer);
mainBuffer(currentind) = outBuffer;
currentind = currentind + 1;
if currentind > bufferAmt
    currentind = 1;
end

rms_vals = calc_rms2(outBuffer);
% if RMS rises, do prerecording step
max_rms = max(rms_vals);
if  max_rms > threshold
    inind = currentind-1;
    if inind < 1
        inind = bufferAmt;
    end
    STOPind = mod(inind + bufferAmt, bufferAmt)+1;
end

% if RMS falls, do postrecording step
if currentind ~= STOPind
    if currentind > inind + minbufferAmt
        if max_rms < threshold
            outind = currentind + 1;
            recording = false;
        end
    end
else
    outind = STOPind;
    recording = false;
end




% if prerecording and postrecording is done (and long enough), end
if inind && outind
end
end
