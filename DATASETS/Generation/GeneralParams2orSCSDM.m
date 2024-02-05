%% General parameters for 2nd order SC SDM
% P. Manrique Feb 2, 2024

Ain=0.5;
N=65536;
Vr=1;
vhigh=Vr;
vlow=-Vr;
cs1a=10e-12;
ci1a =4*cs1a;
cs1b=0.25e-12;
ci1b=2*cs1b;
cs2=cs1b;
ci2=ci1b;
vosp=5;

% Save parameters
filename = '2ndSCSDM_GP.mat';
save(filename,'Ain','N','Vr','vhigh','vlow','vosp','ci1a','ci1b','ci2','cs1a','cs1b','cs2')