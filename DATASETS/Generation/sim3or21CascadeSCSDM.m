%% Dataset generation, 3rd order SC model
% P. Manrique Feb 5, 2024

clear;
clc;
close all;
tStart = cputime;

% Random values of Bw between 10kHz and 20MHz
Bwmin=1e4;
Bwmax=2e7;
n_Bw = 1e4;
logmin = log10(Bwmin);
logmax = log10(Bwmax);
Bw = 10.^(logmin + (logmax - logmin)*rand(1,n_Bw));


% Values of fs and OSR
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
% fs = [];
% OSR = [];
% for i = 1:n_Bw
%     for k = [4 8 16 32 64 128]
%         fs = [fs, 2*k*Bw(i)];
%         OSR = [OSR, k];
%     end
% end


% Reshaping Bw vector
Bw = repelem(Bw,r);

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
fi = Bw./2;
Adc1 = 10.^(1+2*rand(1,n_sim));
gm1 = 10.^(-5+2*rand(1,n_sim));
io1 = 10.^(-4+2*rand(1,n_sim));

Adc2 = 10.^(1+2*rand(1,n_sim));
gm2 = 10.^(-5+2*rand(1,n_sim));
io2 = 10.^(-4+2*rand(1,n_sim));

%% Simulations
SDMmodel = 'ThirdOrderCascadeSingleBitSC';
load_system(SDMmodel);

SDin(1:n_sim) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim   
    
    ts = 1./fs; 

    SDin(n) = SDin(n).setVariable('Ts', ts(n));
    SDin(n) = SDin(n).setVariable('fs', fs(n));

    SDin(n) = SDin(n).setVariable('M', OSR(n));

    SDin(n) = SDin(n).setVariable('ao1', Adc1(n));
    SDin(n) = SDin(n).setVariable('gm1', gm1(n));
    SDin(n) = SDin(n).setVariable('io1', io1(n));

    SDin(n) = SDin(n).setVariable('ao2', Adc2(n));
    SDin(n) = SDin(n).setVariable('gm2', gm2(n));
    SDin(n) = SDin(n).setVariable('io2', io2(n));

    SDin(n) = SDin(n).setVariable('Bw', Bw(n));


    fprintf(['Simulation input creation ',num2str(n/n_sim*100),'\n'])
end

disp(cputime - tStart)

% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles','3rdSCSDM_GP.mat',...
    'SetupFcn',@()evalin('base','load 3rdSCSDM_GP.mat')); 
disp(cputime - tStart2)
fprintf('Saving Data ...')
osr = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin), [], 1);

adc1 = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin), [], 1);
gm1 = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin), [], 1);
io1 = reshape(arrayfun(@(obj) obj.Variables(6).Value, SDin), [], 1);

adc2 = reshape(arrayfun(@(obj) obj.Variables(7).Value, SDin), [], 1);
gm2 = reshape(arrayfun(@(obj) obj.Variables(8).Value, SDin), [], 1);
io2 = reshape(arrayfun(@(obj) obj.Variables(9).Value, SDin), [], 1);

bw = reshape(arrayfun(@(obj) obj.Variables(10).Value, SDin), [], 1);
fs = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin), [], 1);

snr = reshape(arrayfun(@(obj) obj.SNRArray, SDout),[],1);

alfa = 0.05;
power = (io1 + io2)*(1 + alfa) + io2*(1+alfa);

% Filtering simulations such that SNR > 50
valid_idx = find(snr > 50);
osr = osr(valid_idx);
adc1 = adc1(valid_idx);
gm1 = gm1(valid_idx);
io1 = io1(valid_idx);
adc2 = adc2(valid_idx);
gm2 = gm2(valid_idx);
io2 = io2(valid_idx);
fs = fs(valid_idx);
bw = bw(valid_idx);
power = power(valid_idx);
snr = snr(valid_idx);


data = [snr,bw,power,osr,adc1,gm1,io1,adc2,gm2,io2,fs];

data = array2table(data,'VariableNames',{'SNR', 'Bw', 'Power', 'OSR', 'Adc1', 'gm1', 'Io1','Adc2', 'gm2', 'Io2','fs'});
writetable(data,'3or21CascadeSDM_DataSet2.csv','WriteMode','append')
