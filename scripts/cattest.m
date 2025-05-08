length = 8;
A = zeros((512*length),3);
B = ones(length,512,3);

A(1:512,:) = B(1,:,:);
for i = 2:lenght
    A(512*(i-1):(512*i-1),:) = B(i,:,:);
end
A = A';