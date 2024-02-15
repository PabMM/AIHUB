%% Dataset generation, 2nd order SC model
% P. Manrique Feb 2, 2024

clear;
clc;
close all;

% Random values of Bw between 10kHz and 20MHz
Bwmin=1e4;
Bwmax=2e7;
n_Bw = 20;
logmin = log10(Bwmin);
logmax = log10(Bwmax);
Bw = 10.^(logmin + (logmax - logmin)*rand(1,n_Bw));


% Values of fs and OSR
% fs = [];
% OSR = [];
% for i = 1:n_Bw
%     for k = [32 64 128 256 512]
%         fs = [fs, 2*k*Bw(i)];
%         OSR = [OSR, k];
%     end
% end

OSR_range = [32 64 128 256 512];
r = length(OSR_range);
n = r*n_Bw;
fs = zeros(1,n);
OSR = zeros(1,n);
for i = 1:n_Bw
    for k = 1:r
        fs(r*(i-1)+k) = 2*OSR_range(k)*Bw(i);
        OSR(r*(i-1)+k) = OSR_range(k);
    end
end

% Reshaping Bw vector
Bw = repelem(Bw,r);
%%
% Deleting components k such that fs(k) > fmax
fmax = 3e8;
% comps_to_delete = [];
% for k = 1:n_sim
%     if fs(k) > fmax
%         comps_to_delete = [comps_to_delete, k];
%     end
% end
comps_to_delete = find(fs > fmax);

fs(comps_to_delete) = [];
OSR(comps_to_delete) = [];
Bw(comps_to_delete) = [];

n_sim = length(fs);

% Rest of parameters
fin = Bw./5;
Adc = 10.^(1+2*rand(1,n_sim));
gm = 10.^(-5+2*rand(1,n_sim));
io = 10.^(-4+2*rand(1,n_sim));
Vn = 10.^(-11+4*rand(1,n_sim));

%% Prepare Simulation Parameters Inputs
% from P.Diaz April 19, 2023
SDMmodel = 'SecondOrderSingleBitSC';
load_system(SDMmodel);
variables_filePath = '2ndSCSDM_GP.mat';

SDin(1:n_sim) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim  
    ts=1./fs; 
    SDin(n) = SDin(n).setVariable('M', OSR(n));
    SDin(n) = SDin(n).setVariable('Adc', Adc(n));
    SDin(n) = SDin(n).setVariable('gm', gm(n));
    SDin(n) = SDin(n).setVariable('io', io(n));
    SDin(n) = SDin(n).setVariable('Vn', Vn(n));
    SDin(n) = SDin(n).setVariable('ts', ts(n));
    SDin(n) = SDin(n).setVariable('fs', fs(n));
    SDin(n) = SDin(n).setVariable('Bw', Bw(n));

    fprintf(['Simulation input creation ',num2str(n/n_sim*100),'\n'])
end            
    

% 
% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles',variables_filePath,...
    'SetupFcn',@()evalin('base','load 2ndSCSDM_GP.mat')); 
disp(cputime - tStart2)

%%
osr_dt = reshape(arrayfun(@(obj) obj.Variables(1).Value, SDin),[],1);
adc_dt = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin),[],1);
gm_dt = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin),[],1);
io_dt = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin),[],1);
vn_dt = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin),[],1);
fs_dt = reshape(arrayfun(@(obj) obj.Variables(7).Value, SDin),[],1);

bw_dt = reshape(arrayfun(@(obj) obj.Variables(8).Value, SDin),[],1);

alfa = 0.05;
power = 2*io_dt*(1 + alfa);
snr = reshape(arrayfun(@(obj) obj.SNRArray, SDout,'UniformOutput',false),[],1);

% 
% error = 63368;
% snr(error) = [];
% power(error) = [];
% bw_dt(error) = [];
% fs_dt(error) = [];
% vn_dt(error) = [];
% io_dt(error) = [];
% gm_dt(error) = [];
% adc_dt(error) = [];
% osr_dt(error) = [];

snr_array = cell2mat(snr);

% Filtering simulations such that SNR > 50
valid_idx = find(snr_array > 50);
osr_dt = osr_dt(valid_idx);
adc_dt = adc_dt(valid_idx);
gm_dt = gm_dt(valid_idx);
io_dt = io_dt(valid_idx);
vn_dt = vn_dt(valid_idx);
fs_dt = fs_dt(valid_idx);
bw_dt = bw_dt(valid_idx);
power = power(valid_idx);
snr_array = snr_array(valid_idx);

data = [snr_array,bw_dt,power,osr_dt,fs_dt,adc_dt,gm_dt,io_dt,vn_dt];
data = array2table(data,'VariableNames',{'SNR', 'Bw', 'Power', 'OSR', 'fs', 'Adc','gm','Io','Vn'});
writetable(data,'2ndSCSDM_DataSet2.csv','WriteMode','append')

% Dataset1 considera OSR hasta 256
% Dataset2 considera OSR hasta 512


% %%
% save('variables_2orSCSDM.mat')
% %%
% save('SDout_2orSCSDM.mat','SDout','-v7.3')