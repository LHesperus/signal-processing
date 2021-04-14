function [s,t]=genLFM(fs,f0,B,T)
j=sqrt(-1);
t = -T/2:1/fs:T/2-1/fs;
K=B/T;
s=exp(j*2*pi*f0*t +j*pi*K*t.^2);
%s=cos(2*pi*f0*t +pi*K*t.^2);
end