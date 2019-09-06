function [rxSignal,signal_new]= gen_MASK(signal)
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
lpf_lowf_stop=signal.lpf_lowf_stop;

rolloff=signal.rolloff;
span=signal.span;
sps=signal.sps;
%buf
LOphaseTemp=signal.LOphaseTemp;
LOphaseTemp_ddc=signal.LOphaseTemp_ddc;
baseconvbuf=signal.baseconvbuf;
ddcconvbuf=signal.ddcconvbuf;
baserebuf=signal.baserebuf;
Ifrebuf=signal.Ifrebuf;
ddcrebuf=signal.ddcrebuf;
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

dataMod=MASKmod(dataSymbolsIn,signal);

dataIQ=dataMod;
%% BaseBand mod
%% filter and resample (gen baseband signal)
txSignal=zeros(1,length(dataIQ)*sps);
txSignal(1:sps:end)=dataIQ;
rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
% shape-conv
txSignal=[baseconvbuf,txSignal];
[txSignal,xend]=Conv2(rrcFilter,txSignal);
signal_new.baseconvbuf=xend;
%resample
% txSignal=resample(txSignal,fs,sps*fb);
rebufferlen2=20;
rebufferlen=round(rebufferlen2*fs/(sps*fb));
txSignal= [baserebuf,txSignal];
signal_new.baserebuf=txSignal(end-2*rebufferlen2+1:end);
txSignal=resample(txSignal,fs,sps*fb);
txSignal=txSignal(rebufferlen+1:end-rebufferlen);

if signal.gen_method=="Baseband"
    txlen=length(txSignal);
    t=(0:txlen-1)/fs;
    rxSignal=txSignal.*exp(j*(2*pi*f_offset*t+LOphaseTemp)+j*p_offset);
    signal_new.LOphaseTemp=mod(2*pi*f_offset*(t(end)+t(2))+LOphaseTemp,2*pi);
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
    %resample ->base to IF
   % txSignalIF=resample(txSignal,IFfs,fs);
    rebufferlen2=20;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    txSignal= [Ifrebuf,txSignal];
    signal_new.Ifrebuf=txSignal(end-2*rebufferlen2+1:end);
    txSignal=resample(txSignal,IFfs,fs);
    txSignalIF=txSignal(rebufferlen+1:end-rebufferlen);
    txlen=length(txSignalIF);
    t=(0:txlen-1)/IFfs;
    xc=cos(2*pi*fc*t+LOphaseTemp);
    xs=-sin(2*pi*fc*t+LOphaseTemp);
    signal_new.LOphaseTemp=mod(2*pi*fc*(t(end)+t(2))+LOphaseTemp,2*pi);
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
    signal_new.LOphaseTemp_ddc=mod(2*pi*(fc+f_offset)*(t(end)+t(2))+LOphaseTemp_ddc,2*pi);
	IfToBaseI=xc_ddc.*txSignalIF;
	IfToBaseQ=xs_ddc.*txSignalIF;
	%LPF
	lpf_ddc = fir1(64,lpf_lowf_stop,'low');
    %freqz(lpf_ddc)
% 	IfToBaseI=conv(lpf_ddc,IfToBaseI);
% 	IfToBaseQ=conv(lpf_ddc,IfToBaseQ);
%     lpflen=length(lpf_ddc);
% 
% 	IfToBaseI=IfToBaseI(round((lpflen+1)/2):end-round((lpflen-1)/2));
%     IfToBaseQ=IfToBaseQ(round((lpflen+1)/2):end-round((lpflen-1)/2));
%     IfToBaseI=resample(IfToBaseI,fs,IFfs);

    Ifsignal=IfToBaseI+IfToBaseQ*j;
    Ifsignal=[ddcconvbuf,Ifsignal];
    [Ifsignal,xend]=Conv2(lpf_ddc,Ifsignal);
    signal_new.ddcconvbuf=xend;
    %resample ->downsample
    % 	IfToBaseQ=resample(IfToBaseQ,fs,IFfs);
    rebufferlen2=20;
    rebufferlen=round(rebufferlen2*IFfs/fs);
    Ifsignal= [ddcrebuf,Ifsignal];
    signal_new.ddcrebuf=Ifsignal(end-2*rebufferlen+1:end);
    Ifsignal=resample(Ifsignal,fs,IFfs);
    Ifsignal=Ifsignal(rebufferlen2+1:end-rebufferlen2);
    rxSignal=Ifsignal;

%     rxSignal=IfToBaseI+IfToBaseQ*j;
end
end

function dataM=MASKmod(data,signal)
symorder=signal.encodeType;
M=signal.M;
    if symorder=="Gray"
        dataM = bin2gray(data,'psk',M);
    end
    if symorder=="bin"
        dataM=data;
    end
end

function [y,xend]=Conv2(h,x)
    hlen=length(h);
    y=conv(h,x);
    y=y(hlen:end-hlen+1);
    xend=x(end-hlen+2:end);
end