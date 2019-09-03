% 用来更新signal参数
function [rxSignal,signal_new]= gen_MQAM(signal)
signal_new=siganl;
%% gen IQ 
dataIn=gen_bindata(n);                               % Generate vector of binary data
dataInMatrix = reshape(dataIn,length(dataIn)/k,k);   % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                 % Convert to integers

if(signal.encodeType=)
dataMod = qammod(dataSymbolsIn,M,'bin');             % Binary coding, phase offset = 0
dataModG = qammod(dataSymbolsIn,M);                  % Gray coding, phase offset = 0

dataIQ=dataMod;
%% BaseBand mod
%% filter and resample (gen baseband signal)
txSignal=zeros(1,length(dataIQ)*sps);
txSignal(1:sps:end)=dataIQ;
rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
txSignal=conv(txSignal,rrcFilter);
rclen=length(rrcFilter);
txSignal=txSignal(round((rclen+1)/2:end-round((rclen-1)/2)));


figure;plot(txSignal,'x')
rxSignal=conv(txSignal,rrcFilter);
figure;plot(rxSignal)
figure;plot(rxSignal(1:sps:end),'x') 
%% gen IF signal
txSignalIF=resample(rxSignal,IFfs,fs);
txlen=length(txSignalIF);
t=(0:txlen-1)/IFfs;
LOphaseTemp=
xc=cos(2*pi*fc*t+LOphaseTemp);
xs=-sin(2*pi*fc*t+LOphaseTemp);

txSignalIF=real(txSignalIF).*xc+imag(txSignalIF).*xs;

%% Channel
txSignalIF=awgn(txSignalIF,signal.noise,'measured');

%% DDC
txlen=length(txSignalIF);
t=(0:txlen-1)/IFfs;
xc_ddc=cos(2*pi*(fc+f_offset)*t);
xs_ddc=-sin(2*pi*(fc+f_offset)*t);
IfToBaseI=xc_ddc.*txSignalIF;
IfToBaseQ=xs_ddc.*txSignalIF;
figure;
plot(abs(fftshift(fft(IfToBaseI))))
figure;
plot(abs(fftshift(fft(IfToBaseQ))))

lpf_ddc = fir1(64,4*fb/(IFfs/2),'low');
freqz(lpf_ddc)
IfToBaseI=conv(lpf_ddc,IfToBaseI);
IfToBaseQ=conv(lpf_ddc,IfToBaseQ);


IfToBaseI=resample(IfToBaseI,fs,IFfs);
IfToBaseQ=resample(IfToBaseQ,fs,IFfs);

%% return rxSignal


if signal.gen_method=='BaseBand'
    
end
end

