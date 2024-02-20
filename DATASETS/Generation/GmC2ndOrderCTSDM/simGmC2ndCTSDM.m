%% Dataset generation, GmC 2nd Order CT SDM model
% P. Manrique Feb 15, 2024

clear;
clc;
close all;
tStart1 = cputime;

%% Preparing Simulation Parameters Input

n_Bw = 3; n_fs = 2; n_gm = 2; n_GBW = 2; n_IIP3 = 2;

% Values for Bw between 10Mhz and 200Mhz
bw = Bw_fs_range(true,10,0);
for 