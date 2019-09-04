% signal_new:用来更新signal参数
% M=2^k;
function [rxSignal,signal_new]= gen_MQAM(signal)
j=sqrt(-1);
signal_new=signal;
M=signal.M;
k=log2(M);                   % Number of bits per symbol
n=signal.symlen*k;
f_offset=signal.f_offset;
p_offset=signal.p_offset;
fs=signal.fs;
fb=signal.fb;
fc=signal.fc;
IFfs=signal.IFfs;
LOphaseTemp=signal.LOphaseTemp;
LOphaseTemp_ddc=signal.LOphaseTemp_ddc;
lpf_lowf_stop=signal.lpf_lowf_stop;

rolloff=signal.rolloff;
span=signal.span;
sps=signal.sps;
%% gen IQ 
if signal.bindataType=="Random"
    dataBin=randi([0 1],n,1);                             % Generate vector of binary data
end
if signal.bindataType=="External"
    dataBin=signal.dataBin;
    if mod(length(dataBin),k)~=0
        disp('外部导入的二进制长度应该为log2(M)的整数倍');
        return
    end
end
dataInMatrix = reshape(dataBin,length(dataBin)/k,k);  % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                  % Convert to integers

if(signal.encodeType=="bin")
    dataMod = qammod(dataSymbolsIn,M,'bin');             % Binary coding, phase offset = 0
end
if(signal.encodeType=="Gray")
    dataMod = qammod(dataSymbolsIn,M);                  % Gray coding, phase offset = 0
end
dataIQ=dataMod;
%% BaseBand mod
%% filter and resample (gen baseband signal)
txSignal=zeros(1,length(dataIQ)*sps);
txSignal(1:sps:end)=dataIQ;
rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
txSignal=conv(txSignal,rrcFilter);
rclen=length(rrcFilter);
txSignal=txSignal(round((rclen+1)/2:end-round((rclen-1)/2)));
txSignal=resample(txSignal,fs,sps*fb);
if signal.gen_method=="Baseband"
    txlen=length(txSignal);
    t=(0:txlen-1)/fs;
    rxSignal=txSignal.*exp(j*(2*pi*f_offset*t+LOphaseTemp)+j*p_offset);
    signal_new.LOphaseTemp=mod(2*pi*f_offset*t(end)+LOphaseTemp,2*pi);
   %% channel
    if signal.noisePowType=="SNR"
        rxSignal=awgn(rxSignal,signal.noise,'measured');
    end
    if signal.noisePowType=="EbNo"
        EbNo=signal.noise;
        snr = EbNo + 10*log10(k) - 10*log10(fs/fb);
        rxSignal=awgn(rxSignal,snr,'measured');
    end
    return
end
% figure;plot(txSignal,'x')
% rxSignal=conv(txSignal,rrcFilter);
% figure;plot(rxSignal)
% figure;plot(rxSignal(1:sps:end),'x') 
%% gen IF signal
if signal.gen_method=="IF"||signal.gen_method=="IF2Base"
    txSignalIF=resample(txSignal,IFfs,fs);
    txlen=length(txSignalIF);
    t=(0:txlen-1)/IFfs;
    xc=cos(2*pi*fc*t+LOphaseTemp);
    xs=-sin(2*pi*fc*t+LOphaseTemp);
    signal_new.LOphaseTemp=mod(2*pi*fc*t(end)+LOphaseTemp,2*pi);
    txSignalIF=real(txSignalIF).*xc+imag(txSignalIF).*xs; 
    if signal.noisePowType=="SNR"
       rxSignal=awgn(txSignalIF,signal.noise,'measured');
    end
    if signal.noisePowType=="EbNo"
       EbNo=signal.noise;
       snr = EbNo + 10*log10(k) - 10*log10(IFfs/fb);%这里应该是fs，还是IFfs?
       rxSignal=awgn(txSignalIF,snr,'measured');
    end
    if signal.gen_method=="IF"
        return
    end
end
if signal.gen_method=="IF2Base"
	%% DDC
	txSignalIF=rxSignal;
	txlen=length(txSignalIF);
	t=(0:txlen-1)/IFfs;
	xc_ddc=cos(2*pi*(fc+f_offset)*t+LOphaseTemp_ddc+p_offset);
	xs_ddc=-sin(2*pi*(fc+f_offset)*t+LOphaseTemp_ddc+p_offset);
    signal_new.LOphaseTemp_ddc=mod(2*pi*(fc+f_offset)*t(end)+LOphaseTemp_ddc,2*pi);
	IfToBaseI=xc_ddc.*txSignalIF;
	IfToBaseQ=xs_ddc.*txSignalIF;
	%LPF
	lpf_ddc = fir1(64,lpf_lowf_stop,'low');
    %freqz(lpf_ddc)
	IfToBaseI=conv(lpf_ddc,IfToBaseI);
	IfToBaseQ=conv(lpf_ddc,IfToBaseQ);
    lpflen=length(lpf_ddc);

	IfToBaseI=IfToBaseI(round((lpflen+1)/2):end-round((lpflen-1)/2));
    IfToBaseQ=IfToBaseQ(round((lpflen+1)/2):end-round((lpflen-1)/2));

	IfToBaseI=resample(IfToBaseI,fs,IFfs);
	IfToBaseQ=resample(IfToBaseQ,fs,IFfs);
    rxSignal=IfToBaseI+IfToBaseQ*j;
end
end

