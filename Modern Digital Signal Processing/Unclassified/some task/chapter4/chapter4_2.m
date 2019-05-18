clc
clear all
close all
j=sqrt(-1);
N=4;
% 512,1024,2048,4096
L=4096   ;            %signal length
sigma_v_2=0.0731;      %noise power
for nn=1:100
	v=sqrt(sigma_v_2)*randn(1,L);
	b=1;
	a=[1 -0.975 0.95];
	z=filtic(b,a,[0 0]);
	u=filter(b,a,v,z);
	
	sigma_u_2=mean(u.^2);
    for m=0:L-1
    r_n(m+1)=sum(conj(u(1:L-m)).*u(m+1:L))/L;
    end
    R=[r_n(1) r_n(2);r_n(2)' r_n(1)];
    for m=0:L-1
        p_neg_n(m+1)=sum(u(1:L-m).*conj(u(m+1:L)))/L;
    end	
    p=[p_neg_n(1) p_neg_n(2)]';
    [V,D] = eig(R);
    lamada_max=max(diag(D))
    lamada_min=min(diag(D));
    lamada_av=mean(diag(D));
    mu_max=2/lamada_max;
	mu=0.01
    tao_av=1/(2*mu*lamada_av);
    M=2/(4*tao_av);
    X_R=lamada_max/lamada_min;
	%% LMS
	w=zeros(2,L);
	w_se=zeros(2,L);
	w_sr=zeros(2,L);
	w_ss=zeros(2,L);
	w_nlms=zeros(2,L);


	d_est=zeros(1,L);
	d_se_est=zeros(1,L);
	d_sr_est=zeros(1,L);
	d_ss_est=zeros(1,L);
	d_nlms_est=zeros(1,L);
	
	e=zeros(1,L);
	e_se=zeros(1,L);
	e_sr=zeros(1,L);
	e_ss=zeros(1,L);
	e_nlms=zeros(1,L);
	u=[0 0 u];
	for ii=2:L
		%% LMS
		w(:,ii+1)=w(:,ii)+mu*conj(u(ii:-1:ii-1)')*conj(e(ii));
		d_est(ii+1)=w(:,ii+1)'*conj(u(ii+1:-1:ii)');
		e(ii+1)=u(ii+2)-d_est(ii+1);
		
		%% sign-error LMS
		csgn_e(ii)=sign(real(conj(e_se(ii))))+sign(imag(conj(e_se(ii))))*j;
		w_se(:,ii+1)=w_se(:,ii)+mu*conj(u(ii:-1:ii-1)')*csgn_e(ii);
		d_se_est(ii+1)=w_se(:,ii+1)'*conj(u(ii+1:-1:ii)');
		e_se(ii+1)=u(ii+2)-d_se_est(ii+1);
		
		%% sign regressor LMS
		w_sr(:,ii+1)=w_sr(:,ii)+mu*sign(conj(u(ii:-1:ii-1)'))*e_sr(ii);
		d_sr_est(ii+1)=w_sr(:,ii+1)'*conj(u(ii+1:-1:ii)');
		e_sr(ii+1)=u(ii+2)-d_sr_est(ii+1);
		%% sign-sign LMS
		w_ss(:,ii+1)=w_ss(:,ii)+mu*sign(conj(u(ii:-1:ii-1)'))*sign(e_ss(ii));
		d_ss_est(ii+1)=w_ss(:,ii+1)'*conj(u(ii+1:-1:ii)');
		e_ss(ii+1)=u(ii+2)-d_ss_est(ii+1);
		%% NLMS
		w_nlms(:,ii+1)=w_nlms(:,ii)+mu/(0.001+norm(u(ii:-1:ii-1),2))*conj(u(ii:-1:ii-1)')*conj(e_nlms(ii));
		d_nlms_est(ii+1)=w_nlms(:,ii+1)'*conj(u(ii+1:-1:ii)');
		e_nlms(ii+1)=u(ii+2)-d_nlms_est(ii+1);
		
		J(nn,ii-1)=mean(u.^2)-conj(p)'*w(:,ii);
		J_se(nn,ii-1)=mean(u.^2)-conj(p)'*w_se(:,ii);
		J_sr(nn,ii-1)=mean(u.^2)-conj(p)'*w_sr(:,ii);
		J_ss(nn,ii-1)=mean(u.^2)-conj(p)'*w_ss(:,ii);
		J_nlms(nn,ii-1)=mean(u.^2)-conj(p)'*w_nlms(:,ii);
	end
end
figure
plot(J(end,:))
hold on
plot(mean(J));
xlabel('Iteration times')
ylabel('J_n')
legend('typical', 'mean')
title('LMS');

figure
plot(J_se(end,:))
hold on
plot(mean(J_se));
xlabel('Iteration times')
ylabel('J_n')
legend('typical', 'mean')
title('sign-error LMS');

figure
plot(J_sr(end,:))
hold on
plot(mean(J_sr));
xlabel('Iteration times')
ylabel('J_n')
legend('typical', 'mean')
title('sign regressor LMS');

figure
plot(J_ss(end,:))
hold on
plot(mean(J_ss));
xlabel('Iteration times')
legend('typical', 'mean')
title('sign-sign LMS');

figure
plot(J_nlms(end,:))
hold on
plot(mean(J_nlms));
xlabel('Iteration times')
ylabel('J_n')
legend('typical', 'mean')
title('NLMS');
%figure
%plot(w(1,:))
%hold on
%plot(w(2,:))
%
%figure
%plot(w_se(1,:))
%hold on
%plot(w_se(2,:))
%
%figure
%plot(w_sr(1,:))
%hold on
%plot(w_sr(2,:))
%
%figure
%plot(w_ss(1,:))
%hold on
%plot(w_ss(2,:))


%figure
%plot(w_nlms(1,:))
%hold on
%plot(w_nlms(2,:))
%xlabel('Iteration times')


%% AR power spectrum 
u=u(3:end);
for m=0:L-1
    r_n(m+1)=sum(conj(u(1:L-m)).*u(m+1:L))/L;
end
J_min=r_n(1)-r_n(2:3)*w(:,end);
a=[1 -w(:,end)'];
omg=2*pi*(-0.5:0.01:0.5);
for ww=1:size(omg,2)
  S_AR(ww)=J_min/abs(a*exp(-j*(0:2)*omg(ww))');
end
figure
plot(omg/2/pi,S_AR)
xlabel('\omega /2 pi')
ylabel('S_{AR}')
a1=0.975;
a2=-0.95;
(1-a2)/(1+a2)*(0.0731/((1-a2)^2-a1^2))