% M->IQ constellation
%
function [dataMod,newPhase]=pskdec2mod(data,signal)
M=signal.M;
symorder=signal.encodeType;
ModType=signal.type;
InitPhase=signal.InitPhase;
% encode Type
if symorder=="Gray"
    dataM = bin2gray(data,'psk',M);
end
if symorder=="bin"
    dataM=data;
end
% modelate Type
switch ModType
    case "MPSK"
        dataMod=pskmod(dataM,M,InitPhase);
        newPhase=InitPhase;
    case "MDPSK"
        dataMod=Mdpskmod(dataM,M,InitPhase);
        newPhase=angle(dataMod(end));
    case "OQPSK"
        [lastPhase,dataMod]=oqpskMod(dataM,InitPhase);
        newPhase=lastPhase;
    case "pi4DQPSK"
         dataMod=pi4dqpskMod(dataM,InitPhase);
         newPhase=angle(dataMod(end));
    otherwise
        dataMod=pskmod(dataM,M,InitPhase);
end

end
%Differential phase shift keying modulation
function dataMod=Mdpskmod(dataM,M,InitPhase)
j=sqrt(-1);

for ii=1:M
    dataM(dataM==ii-1)=(ii-1)*2*pi/M;
end

dataMod=InitPhase+cumsum(dataM);

dataMod=exp(j*dataMod);

end

% OQPSK mod
function [lastPhase,dataMod]=oqpskMod(dataM,InitPhase)
    j=sqrt(-1);
    dataMod=pskmod(dataM,4,pi/4);
    if size(dataMod,1)>1
        dataMod=dataMod.';
    end
    dataMod=reshape([dataMod;dataMod],1,[]);
    lastPhase=angle(dataMod(end));
    %offset--Q dalay T/2
    dataMod=real(dataMod)+imag([exp(j*InitPhase),dataMod(1:end-1)])*j;
end

% pi4DQSPK
function dataMod=pi4dqpskMod(dataM,InitPhase)
    j=sqrt(-1);
    diffphase=[pi/4,3*pi/4,-pi/4,-3*pi/4];
    M=4;
    for ii=1:M
        dataM(dataM==ii-1)=diffphase(ii);
    end   
    dataMod=InitPhase+cumsum(dataM);
    dataMod=exp(j*dataMod);
end