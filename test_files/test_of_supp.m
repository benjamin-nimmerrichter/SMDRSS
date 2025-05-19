bufferSizes = [256, 512, 1024];
sampleRates = [44100, 48000, 96000];


S = devices_and_support(sampleRates,bufferSizes);
[A,B] = list_vals(S(1).buffer);
[C,D] = list_vals(S(1).fs);
