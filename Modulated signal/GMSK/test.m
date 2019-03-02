clc
clear

Rs=10e2;                                        %bit ratio
Ts=1/Rs;
N=10;                                          %Number of bits to process
fc=20e2;                                        %carrier frequency
fs=10e4;                                        %sample frequency
T=1/fs;
t=(0:(round(N*Ts/T)-1))*T;
r=Ts/T;

%% Orthogonal carrier wave
xc=cos(2*pi*fc*t);
xs=sin(2*pi*fc*t);

%% Gaussian Filter
BTs=0.3;
B=BTs/Ts;
alpha=sqrt(log(2)/2)/B;
h=sqrt(pi)/alpha*exp(-(pi/alpha*t).^2);
%h=h/h(1);
figure;
plot(h)

%% gengerate bit sequence
a=2*(rand(1,N)>0.5)-1;
a=[1,1,-1,1,-1,-1,1,1,-1,1] %%test signal
%a=[1,1,1,-1,-1,1,1,1,-1,-1]
a=a/(2*Ts);
a_sample=repmat(a,r,1);
a_sample=a_sample(:)';
figure;
subplot(6,1,1)
plot(a_sample)
set(gca,'xticklabel',[]);
set(gca,'position',[0.15 5.1/6 0.75 0.9/6])
axis([0 length(a_sample) -2 2])
ylabel('a(t)')
%% Differential coding

b=ones(1,N);
b(1)=a(1);
for jj=2:N
   if a(jj)==1
       b(jj)=b(jj-1);
   else
       b(jj)=-b(jj-1);
   end
end
b=b/(Ts);
b_sample=repmat(b,r,1);
b_sample=b_sample(:)';
figure
plot(b_sample);
figure
bt = .3;          % 3-dB bandwidth-symbol time
o = r;            % Oversampling factor
n = 3;            % 2 symbol periods to the filters peak
h = gaussfir(bt,n,o); 
plot(h)

figure
%b_sample=conv(b_sample,h(r*n:end));
b_sample=conv(b_sample,h);
plot(b_sample)

%% g_t
g=1/2*erfc(2*pi*B*(t-0.5*Ts)/sqrt(2*log(2)))-1/2*erfc(2*pi*B*(t+0.5*Ts)/sqrt(2*log(2)));




%% filtering and integral
b_sample=conv(b_sample,h);
max(b_sample)
phi=zeros(1,length(t));
for jj=2:length(t)
    phi(jj)=pi/(2)*trapz(t(1:jj),a_sample(jj)*g(1:jj));
end

theta=2*pi*fc*t+phi;
