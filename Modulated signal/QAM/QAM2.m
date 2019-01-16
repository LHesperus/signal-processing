%generate MQAM
%code in matlab help file:Compute BER for a QAM System with AWGN Using MATLAB
clc
clear

%% Setup
% Define parameters.
M = 16;                 % Size of signal constellation
k = log2(M);            % Number of bits per symbol
n = 3e4;                % Number of bits to process
nsamp = 1;              % Oversampling rate
hMod = comm.RectangularQAMModulator(M); % Create a 16-QAM modulator

%% Signal Source
% Create a binary data stream as a column vector.
x = randi([0 1],n,1); % Random binary data stream

% Plot first 40 bits in a stem plot.
stem(x(1:40),'filled');
title('Random Bits');
xlabel('Bit Index'); ylabel('Binary Value');


%% Bit-to-Symbol Mapping
% Convert the bits in x into k-bit symbols.
hBitToInt = comm.BitToInteger(k);


xsym = step(hBitToInt,x);

%% Stem Plot of Symbols
% Plot first 10 symbols in a stem plot.
figure; % Create new figure window.
stem(xsym(1:10));
title('Random Symbols');
xlabel('Symbol Index'); ylabel('Integer Value');

%% Modulation
y = modulate(modem.qammod(M),xsym); % Modulate using 16-QAM.


%% Transmitted Signal
ytx = y;

%% Channel
% Send signal over an AWGN channel.
EbNo = 10; % In dB
snr = EbNo + 10*log10(k) - 10*log10(nsamp);
hChan = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', ...
    'SNR',snr);
hChan.SignalPower = (ytx' * ytx)/ length(ytx);
ynoisy = step(hChan,ytx);

%% Received Signal
yrx = ynoisy;

%% Scatter Plot
% Create scatter plot of noisy signal and transmitted
% signal on the same axes.
h = scatterplot(yrx(1:nsamp*5e3),nsamp,0,'g.');
hold on;
scatterplot(ytx(1:5e3),1,0,'k*',h);
title('Received Signal');
legend('Received Signal','Signal Constellation');
axis([-5 5 -5 5]); % Set axis ranges.
hold off;

