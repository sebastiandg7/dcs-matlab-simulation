B = [0 0 1 1; 1 0 1 0];
T = [0 1 1; 2 1 0];

D = bi2de(B)     
E = bi2de(B,'left-msb')     
F = bi2de(T,3)