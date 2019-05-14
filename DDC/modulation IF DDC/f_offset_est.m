
function f_offset=f_offset_est(s,fs,m)
N=length(s);
f=(-N/2:N/2-1)*(fs/N);
S=abs(fftshift(fft(s.^m)));
p_max=find(S==max(S));
f_offset=f(p_max)/m;
end 