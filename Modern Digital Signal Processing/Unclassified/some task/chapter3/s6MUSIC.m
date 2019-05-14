clear all
close all
j=sqrt(-1);
L=100;  %time of sim
N=2^8; %length of  signal
M=32;   %max delay
n=0:N-1;
k=2
f=[0.15,0.17]%,0.26, 0.35];

%for ii=1:L
	phi_k=2*pi*rand(1,2);             %phase [0 2pi]
	a=rand(1,3);
    a=[1 2 ];
	a_k=a.*exp(j*phi_k);       %|a_k|?
    
	s_1=a_k(1)*exp(j*2*pi*f(1)*n);
	s_2=a_k(2)*exp(j*2*pi*f(2)*n);
	%s_3=a_k(3)*exp(j*2*pi*f(3)*n);
   % s_4=a_k(4)*exp(j*2*pi*f(4)*n);
	s_n=[s_1;s_2];%;s_3;s_4];
	v_1=awgn(s_1,20,'measured');
	v_2=awgn(s_2,25,'measured');
	%v_3=awgn(s_3,30,'measured');
  %  v_4=awgn(s_4,30,'measured');
	v=[v_1;v_2];%;v_3;v_4];
	u=sum(v);     %signal 
	
	
	%r_1(m)=1/N*\sum{n=0}{N-1}u_N(n)*u_N_*(n-m)  |m|<=N-1
	
	m=-M+1:M;        %delay of two signal
	%figure
	%r_1=conv(u,u)/N;
		%r_1=zeros(1,size(m));
	r_1_m=0;
	for mm=1:size(m,2);
		if m(mm)>=0 
		for nn=m(mm)+1:N
			r_1_m=r_1_m+conj(u(nn))*u(nn-m(mm));
          % r_1_m=r_1_m+u(nn)*conj(u(nn-m(mm)));
		end
		else
		for nn=1:N+m(mm);
			r_1_m=r_1_m+u(nn)*conj(u(nn-m(mm)));
		end
		end
	
		r_1(mm)=r_1_m/N;
		r_1_m=0;
        
    end
    %figure
	%	r_1=r_1(m(1)+N:m(end)+N)/max(r_1);
	%    plot(abs(fft(r_1)))

	r_1=r_1/max(r_1);
	
	M=8;
	for aa=1:M
		for bb=aa:M
			R(aa,bb)=r_1(aa-bb+M);
		end
	end
	R=R+R'-diag(r_1(M)*ones(1,M));
    [eig_vector,eig_value]=eig(R);
   % eig_value=abs(eig_value);
    eig_value=diag(eig_value)
    for kk=1:M-k
       eig_max(kk)=find(eig_value==min(eig_value));
       eig_value(eig_max(kk))=1000;
       G(:,kk)=eig_vector(:,eig_max(kk));
    end
    
	w_len=1000;
	for w=1:w_len
		a_w=exp(-j*2*pi*( (w-w_len/2)/w_len)*(0:M-1));
        %aGGa(w)=abs( (a_w)*G*G'*(a_w'));
       % min_aGGa(w)=find(aGGa==min(aGGa(w)));
        P_MUSIC(w)=1/abs( (a_w)*G*G'*(a_w'));
		%P_MVDR(w)=1/abs((conj(a_w)*invR*conj(a_w')));
	end
	P_MUSIC=abs(P_MUSIC)/max(abs(P_MUSIC));
	[peak_value,peak_pos]=findpeaks(log10(P_MUSIC));

    for kk=1:k
        fk_pos(kk)=find(peak_value==max(peak_value));
        peak_value(fk_pos(kk))=-100;
        angle(a_w(fk_pos(kk)))
        f_est(kk)=peak_pos(fk_pos(kk));
     end
	f_est=sort(f_est)*(1/w_len)-0.5;
figure
	%plot(-0.5:1/w_len:0.5-1/w_len,log10(P_MUSIC))
plot(0:1/w_len:0.5-1/w_len,log10(P_MUSIC(w_len/2+1:end)))
title('MUSIC')
%end