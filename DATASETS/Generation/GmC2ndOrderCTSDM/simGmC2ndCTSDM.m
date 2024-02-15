%% Dataset generation, GmC 2nd Order CT SDM model
% P. Manrique Feb 15, 2024

clear;
clc;
close all;
tStart1 = cputime;

%% Preparing Simulation Parameters Input

% Random values of Bw between 10kHz and 20MHz
Bwmin=1e4;
Bwmax=2e7;
n_Bw = 5;
logmin = log10(Bwmin);
logmax = log10(Bwmax);
Bw = logspace(logmin,logmax,n_Bw);
