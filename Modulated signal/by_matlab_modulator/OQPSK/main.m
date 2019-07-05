
clc
clear
close all


%% modulate
oqpskmod = comm.OQPSKModulator('BitInput',true);
oqpskdemod = comm.OQPSKDemodulator('BitOutput',true);
channel = comm.AWGNChannel('EbNo',4,'BitsPerSymbol',2);
 
%%
errorRate = comm.ErrorRate('ReceiveDelay',2);

%%
for counter = 1:300
    txData = randi([0 1],100,1);
    modSig = oqpskmod(txData);
    rxSig = channel(modSig);
    rxData = oqpskdemod(rxSig);
    errorStats = errorRate(txData,rxData);
end

%%
ber = errorStats(1)
numErrors = errorStats(2)
numBits = errorStats(3)