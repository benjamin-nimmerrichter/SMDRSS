clearvars
Nchannels = 1;
devs = struct([]);
devs(1).name = "";
devs(1).ID = "";
for counter = 1:audiodevinfo(1) % n input devices
    devs(counter).name = audiodevinfo().input(counter).Name;
    devs(counter).ID = audiodevinfo().input(counter).ID;
    if audiodevinfo(1,devs(counter).ID,44100,16,Nchannels)
        devs(counter).supp(1) = 1; % 44 k
        devs(counter).supp(4) = 1; % 16b
    else 
        devs(counter).supp(1) = 0; % 44 k
        devs(counter).supp(4) = 0; % 16b
    end
    if audiodevinfo(1,devs(counter).ID,48000,16,Nchannels)
        devs(counter).supp(2) = 1; % 48 k
        devs(counter).supp(4) = 1; % 16b
    else 
        devs(counter).supp(2) = 0; % 48 k
    end
    if audiodevinfo(1,devs(counter).ID,96000,16,Nchannels)
        devs(counter).supp(3) = 1; % 96 k
        devs(counter).supp(4) = 1; % 16b
    else 
        devs(counter).supp(3) = 0; % 96 k
    end
    if audiodevinfo(1,devs(counter).ID,44100,24,Nchannels)
        devs(counter).supp(1) = 1; % 44 k
        devs(counter).supp(5) = 1; % 24b
    else 
        devs(counter).supp(1) = 0; % 44 k
        devs(counter).supp(5) = 0; % 24 b
    end
    if audiodevinfo(1,devs(counter).ID,48000,24,Nchannels)
        devs(counter).supp(2) = 1; % 48k
        devs(counter).supp(5) = 1; % 24b
    end
end
