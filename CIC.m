function out = CIC(in,R)
    sz = ceil(length(in)/R);
    out = zeros(sz,1)';

    if in < sz*R
        ext = zeros(sz*R-length(in),1);
        vertcat(in,ext);
    end

    int_last = 0;
    comb_last = 0;
    count = 1;
    
    for sample = 1:sz*R
        int = in(sample) + int_last;
        int_last = int;

        if mod(sample,R) == 0
            out(count) = int - comb_last;
            count = count+1;
            comb_last = int;
        end
    end
end

