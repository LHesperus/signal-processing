clc
clear
close all
%% 
fs=10e3;
f0=1e3;
L=100;
t=(0:L-1)/fs;
x=sin(2*pi*f0*t);
X=fftshift(fft(x));
%%
ff=(-L/2:L/2-1)*(fs/L);
figure
subplot(2,1,1)
stem(t,x)
subplot(2,1,2)
plot(ff,abs(X))
suptitle('source signal')
%%
n=2;
x=[x;zeros(n,L)];
y=reshape(x,1,(n+1)*L);
fs=(n+1)*fs;
L=(n+1)*L;
ff=(-L/2:L/2-1)*(fs/L);
t=(0:L-1)/fs;

Y=fftshift(fft(y));
figure
subplot(2,1,1)
stem(t,y)
subplot(2,1,2)
plot(ff,abs(Y))
suptitle('Interpolation')

%% CIC
D=n+3;
h=ones(1,D);
y_fil=conv(y,h);
%y_fil=conv(y_fil,h); %% CIC - CIC
Y_fil=fftshift(fft(y_fil));
y_cic=y_fil(1:D:end);
Y_cic=fftshift(fft(y_cic));
figure
subplot(2,1,1)
stem(y_fil)
subplot(2,1,2)
stem(y_cic)

figure
subplot(2,1,1)
plot(abs(Y_fil))
subplot(2,1,2)
plot(abs(Y_cic))

%% equivalent CIC 
y_fil2=sum(y(1:1+D));
for ii=2+D:D:length(Y)-D    
    y_fil2=[y_fil2, sum(y(ii:ii+D))];
end
Y_fil2=fftshift(fft(y_fil2));
figure
stem(y_fil2)
figure
plot(abs(Y_fil2))
