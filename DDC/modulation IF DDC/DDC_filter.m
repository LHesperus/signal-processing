%%
% fpass : lowpass filter pass freq,Hz
%f_order :butter filter order
% in :   IF signal
%a,b:    gain
%phase1¡¢2:phase deviation
%I¡¢Q :DDC output
function [I,Q]=DDC_filter(fs,fc,fpass,f_order,in,a,b,phase1,phase2)
len=size(in,2);
t=(0:len-1)/fs;
NCO_I=a*cos(2*pi*fc*t+phase1);
NCO_Q=-b*sin(2*pi*fc*t+phase2);
y_i=NCO_I.*in;
y_q=NCO_Q.*in;
[b,a] = butter(f_order,2*fpass/fs,'low');
figure
freqz(b,a)
I = filter(b,a,y_i);
Q = filter(b,a,y_q);
end