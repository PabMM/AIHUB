close all;

%% 2nd order SC SDM (1st dataset)
% table2or = readtable('2ndSCSDM_DataSet.csv');
% data0 = table2array(table2or(2:end, :));
% 
% figure;
% scatter3(data0(:,1), data0(:,2), data0(:,3), 10, 'filled');
% xlabel('SNR');
% ylabel('Bw');
% zlabel('Power');
% title('2nd Order SC SDM DataSet');
% 
% set(gca, 'YScale','log');

% %% 2nd order SC Single Bit SDM (2nd dataset)
% table2or = readtable('2ndSCSDM_DataSet2.csv');
% data2 = table2array(table2or(2:end, :));
% 
% figure;
% scatter3(data2(:,1), data2(:,2), data2(:,3), 10, 'filled');
% xlabel('SNR');
% ylabel('Bw');
% zlabel('Power');
% title('2nd Order SC SDM DataSet');
% 
% set(gca, 'YScale','log');
% 
% 
% %% 3rd order 2-1 Cascade SC SDM
% table3or = readtable("3or21CascadeSDM_DataSet2.csv");
% data3 = table2array(table3or(2:end, :));
% 
% figure;
% scatter3(data3(:,1), data3(:,2), data3(:,3), 10, 'filled');
% xlabel('SNR');
% ylabel('Bw');
% zlabel('Power');
% title('3rd Order 2-1 Cascade SC SDM DataSet');
% 
% set(gca, 'YScale','log');
% 
% %% 4th order 2-1-1 Cascade SC SDM
% table4or = readtable("211CascadeSDM_DataSet.csv");
% data4 = table2array(table4or(2:end, :));
% 
% figure;
% scatter3(data4(:,1), data4(:,2), data4(:,3), 10, 'filled');
% xlabel('SNR');
% ylabel('Bw');
% zlabel('Power');
% title('4th Order 2-1-1 Cascade SC SDM DataSet');
% 
% set(gca, 'YScale','log');
% 
% %% 2nd order SC Multibit SDM
% table2mb = readtable('2ndSCmultibitSDM_DataSet.csv');
% data2m = table2array(table2mb(2:end, :));
% 
% figure;
% scatter3(data2m(:,1), data2m(:,2), data2m(:,3), 10, 'filled');
% xlabel('SNR');
% ylabel('Bw');
% zlabel('Power');
% title('2nd Order SC Multibit SDM DataSet');
% 
% set(gca, 'YScale','log');
% 
% %% Discrete time models datasets
% 
% len2ndSB = size(data2,1);
% col2ndSB = zeros(len2ndSB,1);
% ds2ndSB = [data2(:,1),data2(:,2),data2(:,3),col2ndSB];
% 
% len3rd = size(data3,1);
% col3rd = ones(len3rd,1);
% ds3rd = [data3(:,1),data3(:,2),data3(:,3),col3rd];
% 
% len4th = size(data4,1);
% col4th = 2*ones(len4th,1);
% ds4th = [data4(:,1),data4(:,2),data4(:,3),col4th];
% 
% len2ndMB = size(data2m,1);
% col2ndMB = 3*ones(len2ndMB,1);
% ds2ndMB = [data2m(:,1),data2m(:,2),data2m(:,3),col2ndMB];
% 
% ds = [ds2ndSB; ds3rd; ds4th; ds2ndMB];
% 
% figure;
% 
% % Create scatter plots for each class with custom legend labels
% uniqueLabels = unique(ds(:, 4));
% 
% legendLabels = {'2orSCSDM Single Bit', '3orCascadeSDM', '211CascadeSDM', '2orSCSDM Multi Bit'}; % Add your custom labels here
% 
% for i = 1:length(uniqueLabels)
%     currentClass = uniqueLabels(i);
%     indices = (ds(:, 4) == i - 1);
% 
%     scatter3(ds(indices, 1), ds(indices, 2), ds(indices, 3), 5, ds(indices, 4), 'filled', 'DisplayName', legendLabels{i}, 'MarkerFaceAlpha', 0.6);
%     hold on;
% end
% 
% xlabel('SNR');
% ylabel('Bw');
% zlabel('Power');
% title('Discrete Time Models Datasets');
% 
% set(gca,'YScale','log');
% 
% % Show the legend with custom labels
% legend('Location', 'Best');
% 
% saveas(gcf, 'DiscreteTimeModels.png')


% 211 Cascade V2
table4or2 = readtable("211CascadeSDM_DataSet2prueba2.csv");
data42 = table2array(table4or2(2:end, :));

figure;
scatter3(data42(:,1), data42(:,2), data42(:,3), 10, 'filled');
xlabel('SNR');
ylabel('Bw');
zlabel('Power');
title('4th Order 2-1-1 Cascade SC SDM DataSet');

set(gca, 'YScale','log');