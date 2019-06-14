clc
clear
close all

%%
j=sqrt(-1);
L=1024;
n=0:L-1;
%f_n=rand(1,L);
f_n=sin(2*pi*0.01*n);
%f_n=f_n-mean(f_n);
F=fftshift(fft(f_n));

w=pi*linspace(-1,1,L);
z=exp(j*w);
for ii=1:L
    F_z(ii)=sum(f_n.*(z(ii).^n));
end

figure
plot(f_n)
figure
plot(abs(F))
figure
plot(abs(F_z))

%% initial value theorem
syms y x 
y=cos(x);
z=10000000;
ztrans(y,x,z)