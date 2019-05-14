%Generating AM signal
function [y_AM,I_AM,Q_AM]=gen_AM(A,fc,fs,L,m_a,v)
%use orthogonal modulation generate modulated siganl
%You can see the original signal v in the code.
if nargin==0
    A=1;                                                    %%Ampltitude
    fc=1e4;                                                 %carrier frequency
    fs=1e5;                                                 %sample frequency
    L=10000;                                                %length of signal
    m_a=0.3;                                                %modulation index,|m_a|<1

end
T=1/fs;                                                 %sample time
t=(0:L-1)*T;                                            %time vector
if nargin==0
    v=A*cos(2*pi*1000*t);                                   %modulation signal
end
xs=sin(2*pi*fc*t);
xc=cos(2*pi*fc*t);
                                               
I_AM=A+m_a*v;
Q_AM=0;
y_AM=I_AM.*xc+Q_AM.*xs;


