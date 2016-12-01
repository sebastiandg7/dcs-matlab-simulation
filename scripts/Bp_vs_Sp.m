%% simulación
M = 4;
k = 2;
SNR_DB=-5:0.01:20;
snr= 10.^(SNR_DB/10); %lineaización
argum = sqrt((3/(M-1))*snr);
Q = erfc(argum)/sqrt(2); 
Psc = 2*(1-(1/sqrt(M)))*Q;
Ps = 1-(1-Psc).^2;
Pb=Psc/(k/2); 

figure(4);
semilogy(SNR_DB,Ps); hold on; semilogy(SNR_DB,Pb,'-r');
%title('Pb y Ps vs Ys');
xlabel('Ys');
ylabel('Probabilidad de Error de Simbolo');
legend('Probabilidad de Error de Simbolo','Probabilidad de Error de Bit')
axis([-5 max(SNR_DB) 10e-4 1]);
grid on;