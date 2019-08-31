clc
clear 
close all
%% parameter
fs=64e3*40;
Ts=1/fs;
fb=10e3;
Tb=1/fb;
alpha=0.5;
L=256*6;
t=(-L/2:L/2-1)/fs;
t(L/2+1)=1e-9;
%% root raised cosine
h_den=(pi*t/Tb.*(1-(4*alpha*t/Tb).^2));
h1=(sin((1-alpha)*pi*t/Tb)+4*alpha*t/Tb.*cos((1+alpha)*pi*t/Tb))./h_den;
for ii=1:length(h1)
    if(h_den(ii)==0)
        h1(ii)=(h1(ii-1)+h1(ii+1))/2;
    end
end
h1=h1/(2*pi);% 2pi是我随便取的，貌似可以让升余弦峰值为1

h_rcos=conv(h1,h1);
H1=fftshift(fft(h1));
H_rcos=fftshift(fft(h_rcos));
figure
subplot(2,2,1)
plot(h1);title('h')
subplot(2,2,2)
plot(h_rcos);title('conv(h,h)')
subplot(2,2,3)
plot(abs(H1));title('H')
subplot(2,2,4)
plot(abs(H_rcos));title('H rcos')

%% raised cosine
h_den=(pi*t/Tb.*(1-(2*alpha*t/Tb).^2));
h=sin(pi*t/Tb).*cos(pi*alpha*t/Tb)./h_den;
for ii=1:length(h)
    if(h_den(ii)==0)
        h(ii)=(h(ii-1)+h(ii+1))/2;
    end
end
figure
subplot(2,1,1)
plot(h)
subplot(2,1,2)
plot(abs(fftshift(fft(h))))

% compare
figure
for  alpha=0.2:0.2:0.8
    h_den=(pi*t/Tb.*(1-(2*alpha*t/Tb).^2));
    h=sin(pi*t/Tb).*cos(pi*alpha*t/Tb)./h_den;
    for ii=1:length(h)
    if(h_den(ii)==0)
        h(ii)=(h(ii-1)+h(ii+1))/2;
    end
end
    plot(h)
    hold on
end
hold off
legend('alpha=0.2','alpha=0.4','alpha=0.6','alpha=0.8')
figure
for  alpha=0.2:0.2:0.8
    h_den=(pi*t/Tb.*(1-(2*alpha*t/Tb).^2));
    h=sin(pi*t/Tb).*cos(pi*alpha*t/Tb)./h_den;
    for ii=1:length(h)
        if(h_den(ii)==0)
          h(ii)=(h(ii-1)+h(ii+1))/2;
        end
    end
    H=abs(fftshift(fft(h)));
    plot(H)
    hold on
end
hold off
legend('alpha=0.2','alpha=0.4','alpha=0.6','alpha=0.8')

%% matlab func
rf = 0.6;
span = 6;
sps = 64 ;
h1 = rcosdesign(rf,span,sps,'sqrt');
h_rcos=conv(h1,h1);
figure
subplot(2,2,1)
plot(h1);title('h')
subplot(2,2,2)
plot(h_rcos);title('conv(h,h)')
subplot(2,2,3)
plot(abs(H1));title('H')
subplot(2,2,4)
plot(abs(H_rcos));title('H rcos')

figure
for  rf=0.2:0.2:0.8
    h1 = rcosdesign(rf,span,sps,'normal');
    H=abs(fftshift(fft(h1)));
    plot(H)
    hold on
end
legend('alpha=0.2','alpha=0.4','alpha=0.6','alpha=0.8')

