% Data set Randomly generated
% P. Diaz April 19,2023 

clear;clc;close all;
tStart = cputime;

Bw=2e4;
fin=Bw/5;
% Parameters' values
%n_sim = 5e4;
n_sim = 24;
OSR=[ 128 256 512];
OSR = OSR(randi([1, 3], 1, n_sim));
Adc = 10.^(1+2*rand(1,n_sim));
gm = 10.^(-5+2*rand(1,n_sim));
io = 10.^(-4+2*rand(1,n_sim));
Vn = 10.^(-11+4*rand(1,n_sim));



%% Prepare Simulation Parameters Inputs
SDMmodel = 'SecondOrderMultibitSC';
load_system(SDMmodel);
variables_filePath = '2ndSCmultibitSDM_GP.mat';

SDin(1:length(OSR)) = Simulink.SimulationInput(SDMmodel);
for n = 1:n_sim  
      
    M=OSR(n);
    fs=2*M*Bw;
    ts=1/fs; 
    SDin(n) = SDin(n).setVariable('M', OSR(n));
    SDin(n) = SDin(n).setVariable('Adc', Adc(n));
    SDin(n) = SDin(n).setVariable('gm', gm(n));
    SDin(n) = SDin(n).setVariable('io', io(n));
    SDin(n) = SDin(n).setVariable('Vn', Vn(n));
    SDin(n) = SDin(n).setVariable('ts', ts);
    SDin(n) = SDin(n).setVariable('fs', fs);
                
end            
    

% 
% Run parallel simulations
tStart2 = cputime;
fprintf('Running parallel simulations')
SDout=parsim(SDin,'ShowProgress','on','TransferBaseWorkspaceVariables','off',...
    'AttachedFiles',variables_filePath,...
    'SetupFcn',@()evalin('base','load 2ndSCmultibitSDM_GP.mat')); 
disp(cputime - tStart2)

%%
c1 = reshape(arrayfun(@(obj) obj.Variables(1).Value, SDin),[],1);
c2 = reshape(arrayfun(@(obj) obj.Variables(2).Value, SDin),[],1);
c3 = reshape(arrayfun(@(obj) obj.Variables(3).Value, SDin),[],1);
c4 = reshape(arrayfun(@(obj) obj.Variables(4).Value, SDin),[],1);
c5 = reshape(arrayfun(@(obj) obj.Variables(5).Value, SDin),[],1);


snr = reshape(arrayfun(@(obj) obj.SNRArray, SDout),[],1);
data = [snr,c1,c2,c3,c4,c5];
data = array2table(data,'VariableNames',{'SNR', 'OSR', 'Adc', 'gm', 'Io', 'Vn'});
writetable(data,'random_2orMBSC.csv')

