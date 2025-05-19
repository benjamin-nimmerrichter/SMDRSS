close all
clear all
buffer_amt = 16;
buffsz = 128;
mics = 5;
buffer = zeros(buffer_amt,mics,buffsz);

for t = 0:22
    write = mod(t,buffer_amt)+1;
    out = zeros(mics,buffsz);
    for mic = 1:mics
        out(mic,:) = (1:buffsz)+mic+10*t;
    end
    ind = mod(write,buffer_amt)+1;
    buffer(write,:,:) = out;
    if t == 10; snap1 = buffer; end
    if t == 15; snap2 = buffer; end
    if t == 16; snap3 = buffer; end
end

sn1_1 = get_channel_signal(snap1,1);
sn1_2 = get_channel_signal(snap1,2);

sn2_1 = get_channel_signal(snap2,1);
sn2_2 = get_channel_signal(snap2,2);

sn3_1 = get_channel_signal(snap3,1);
sn3_2 = get_channel_signal(snap3,2);

buff1_1 = get_channel_signal(buffer,1);
buff1_2 = get_channel_signal(buffer,2);

figure
subplot 221
plot(sn1_1)
hold on
plot(sn1_2)
title("Snapshot 1")
subplot 222
plot(sn2_1)
hold on
plot(sn2_2)
title("Snapshot 2")
subplot 223
plot(sn3_1)
hold on
plot(sn3_2)
title("Snapshot 3")
subplot 224
plot(buff1_1)
hold on
plot(buff1_2)
title("Buffer")


function sig = get_channel_signal(buff,chan)
    in = buff(:,chan,:); % consolidate buffer
    perm = permute(in, [2 3 1]);
    % create string of buffers to reconstruct the signal
    sig = reshape(perm,1,[]);
end

