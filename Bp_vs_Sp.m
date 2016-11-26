
M = 4;
k = 2;
SNR_DB=-5:0.01:20;
snr= 10.^(SNR_DB/10); %linealization

argum = sqrt((3/(M-1))*snr);
Q = erfc(argum)/sqrt(2);
csp = (1-(1/M))*Q;
cbp=csp/k;

figure(4);
semilogy(SNR_DB,csp); hold on; semilogy(SNR_DB,cbp,'-r');

xlabel('Ys');
ylabel('Symbol error probability');
legend('Symbol error probability','Bit error probability')
axis([-5 max(SNR_DB) 10e-4 1]);
grid on;