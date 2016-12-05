function[] = bep_vs_bep(mensaje, relacion)

SNR_DB=0:2:10;
snr= 10.^(SNR_DB/10);

M = 4; % Alphabet size
EbN0_min=0;EbN0_max=relacion;step=0.5;
SNR=[];BER=[];
for EbN0 = EbN0_min:step:EbN0_max
SNR_dB=EbN0 + 3; %for QPSK Eb/N0=0.5*Es/N0=0.5*SNR
%x = randi(1000000,1,M);
y=modulate(modem.qammod(M),mensaje);
ynoisy = awgn(y,SNR_dB,'measured');
z=demodulate(modem.qamdemod(M),ynoisy);
[num,rt]= symerr(mensaje,z);
SNR=[SNR EbN0];
BER=[BER rt];
end;

EbNo = 0:0.5:relacion;
[ber, BER] = berawgn(EbNo,'qam',M);
semilogy(SNR,BER,'-r*',SNR,ber,'-bo');grid;title('Bit error rate for QAM over AWGN');
axis([0 relacion 10^(-8) 1]);
legend('BER Simulado','BEP teorico QAM');
xlabel('SNR (dB)');ylabel('Bit Error Probability');
