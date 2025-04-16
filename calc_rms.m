function out = calc_rms(meas,m_columns)
%---calculate RMS value of signal---
out=zeros(m_columns,1);
height=size(meas,1);
meas=reshape(meas,[],1);
for i=(1:(m_columns)) %calculate RMS for each input
    max=(height*i);
    min=1+height*(i-1);
    temp=meas(min:max);
    t_sum=(sum(temp.^2));
    t_mean =t_sum/(size(meas,1)/m_columns);
    
    out(i)=sqrt(t_mean); %output RMS values
end