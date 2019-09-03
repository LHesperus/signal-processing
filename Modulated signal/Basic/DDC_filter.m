function [I,Q]=DDC_filter(fs,fc,fpass,f_order,in)
len=size(in,2);
t=(0:len-1)/fs;
NCO_I=cos(2*pi*fc*t);
NCO_Q=-sin(2*pi*fc*t);
y_i=NCO_I.*in;
y_q=NCO_Q.*in;
[b,a] = butter(f_order,2*fpass/fs,'low');
figure
freqz(b,a)
I = filter(b,a,y_i);
Q = filter(b,a,y_q);
end