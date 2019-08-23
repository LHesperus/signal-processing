clc
clear
close all
%% Data generation
N = 3*10^4; % Number of bits
ip = rand(1,N)>0.5;% Generating 0,1
data = 2*ip-1;
% BPSK modulation
Tsym = 100;% No. of samples per symbol
MSE = zeros(1,5); % A memory for the MSE
BER_sim = zeros(1,5); % A memory for the simulated BER
%% Pulse shape
p = sin(2*pi*(0:Tsym-1)/(2*Tsym));% Sinusoidal wave
%p=rcosdesign(0.5,10,Tsym,'sqrt');
data_up = zeros(1,length(data)*Tsym);% Creation a memory of zeros
data_up(1:Tsym:end) = data; % Interpolation the data
w = conv(data_up,p);% The convolution operation
%% Noise addition
SNRdB=2:2:10; % Signal to Noise Ratio
SNR=10.^(SNRdB/10) ;% The linear values for the noise
for cv=1:length(SNR) % Generate a loop
    noise=sqrt(1/(2*SNR(cv)))*randn(1,length(w));
                        % Noise generation
    received=w+noise;   % Received signal with noise
   % received=conv(received1,p);
%% Detection and Correction
    tau=0;              %Initial value for tau
    delta=Tsym/2;       %The shifting value before and
                        %after the midway sample
    center=60;          %The assumed place for the first
                        %midway sample
    a=zeros(1,N-1);
                        %A memory of zeros for the
                        %earlier samples
    cenpoint=zeros(1,N-1);
                        %A memory of zeros for the
                        %midway samples
    remind=zeros(1,N-1);
                        %A memory of zeros for the remind
    avgsamples=6;       %Six values of Gardner algorithm
                        %are used to find the average
    stepsize=1;          %Correction step size
    rit=0;              %Iteration counter
    GA=zeros(1,avgsamples); %A memory of zeros
    tauvector=zeros(1,1900); %A memory of zeros for tau
                             %vector(2000-100=1900)
    uor=0;                   %A counter for the tau vector
    for ii= (Tsym/2)+1:Tsym:length(received)-(Tsym/2)
        rit=rit+1; %A counter
        midsample=received(center); %The midway sample
        latesample=received(center+delta);%The late sample
        earlysample=received(center-delta);%The early sample                                            
        a(rit)=earlysample; %Save samples
        %% Error detection
         sub=latesample-earlysample;
        %Subtraction process
        GA(mod(rit,avgsamples)+1)=sub*midsample;
        %Gardner Algorithm
        %% Loop filter
        if mean(GA) > 0
            tau =- stepsize;             %Shift by decreasing
        else
            tau = stepsize;  %Shift by increasing
        end
        %% Safe remind values
        cenpoint(rit)=center; %Save positions of
                                %midway samples
        remind(rit)=rem((center-Tsym/2),Tsym);
                                %Save remind values to find
                            % convergence plots
       %% tau vector
        if rit>=100 && rit<2000 %tau vector from 100 to
                                %2000 where the convergence
            uor=uor+1; %happens
            tauvector(uor)= (remind(rit)-(Tsym/2)).^2;
                                    %Difference between the
                                    %estimated tau & the
        end %optimal tau
        %% Correction
        center=center+Tsym+tau; %Adding the tau value
        if center>=length(received)-(Tsym/2)-1
            break; %Break the loop when
                    %the midway sample reaches
                    %to 51 samples before
                        %the last sample
        end
    end
 %% Mean Squared Error (MSE) 
 	 MSE(cv)=mean(tauvector);	%Finding the Mean Squared Error 
 	 %% convergence plot 
 	 figure 
 	 symbols = 200; 
 	 subplot(2,1,1); 
 	 plot(remind(1:symbols), '-' ); 
 	 hold on 
 	 lim1=40*ones(1,symbols); 
 	 lim2=60*ones(1,symbols); 
 	 plot(lim1); 
 	 hold on 
 	 plot(lim2); 
 	 title( 'Convergence plot for BPSK-Gardner' ); 
 	 ylabel( 'tau axis' ), xlabel( 'iterations' ) 
 	 legend( [ 'SNRdB='  int2str(SNRdB(cv))]); 
 	 axis([1 symbols 0 Tsym]); 
 	 subplot(2,1,2); 
 	 symbols = 2000; 
 	 plot(remind(1:symbols), '-' ); 
 	 hold on 
 	 plot(lim1); 
 	 hold on 
 	 plot(lim2); 
 	 title( 'Convergence plot for BPSK-Gardner' ); 
  ylabel( 'tau axis' ), xlabel( 'iterations' ) 
 	 legend( [ 'SNRdB='  int2str(SNRdB(cv))]); 
 	 axis([1 symbols 0 Tsym]); 
 	 %% Calculating the simulated BER 
 	 Error=0;	%Set the initial value for Error 
 	for  k=1:N-1	%Error calculation 
 	if  ((a(k)>0 && data(k)==-1)||(a(k)< 0 && data(k)==1))  
	 	Error=Error+1; 	 
 end 
 	end 
 	 BER_sim(cv)=Error/(N-1);	%Calculate error/bit end 
end
%% Plot SNR Vs BER 
BER_th=(1/2)*erfc(sqrt(2*SNR)/sqrt(2));  	%Calculate The 
	 	 %theoretical BER 
figure 
semilogy(SNRdB,BER_th, 'k-' , 'LineWidth' ,2); %Plot theoretical BER 
hold on 
semilogy(SNRdB,BER_sim, 'r-' , 'LineWidth' ,2);	%Plot simulated BER 
title( 'SNR Vs. BER for BPSK-Gardner technique' ); 
legend( 'Theoretical' , 'Simulation' ); ylabel( 'log BER' ); xlabel( 'SNR in dB' );
