function out = harmonic_gen(A,f,Fs,time)
n_per = linspace(0,round(Fs/f)-1,round(Fs/f));
period = A*cos(2*pi*f*n/Fs);
end