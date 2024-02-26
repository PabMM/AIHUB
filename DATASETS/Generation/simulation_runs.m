% Simulation runs for SC models
% P. Manrique Feb 22, 2024

clear;

addpath(genpath(pwd));

addpath('/home/pmanrique/Documentos/delsig')
addpath('/home/pmanrique/Documentos/SDTOOLBOX_2_MALCOVATI')
addpath('/home/pmanrique/Documentos/SIMSIDES')

%%
% IMPORTANT: CHECK SAME ARGUMENTS FOR Bw_fs_range FUNCTION

% Long run 1: Bw steps 5000, fs steps 12

sim211CascadeSDM_V2;
sim3or21CascadeSCSDM_V2;
sim2ndSCSDM_V2;
sim2ndSCmultibitSDM_V2;