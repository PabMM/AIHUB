close all;

% 2nd order SC SDM
table2or = readtable('2ndSCSDM_DataSet.csv');
data = table2array(table2or(2:end, :));

figure;
scatter3(data(:,1), data(:,2), data(:,3), 10, 'filled');
xlabel('SNR');
ylabel('Bw');
zlabel('Power');
title('2nd Order SC SDM DataSet');

set(gca, 'YScale','log');


% 3rd order 2-1 Cascade SC SDM
table3or  =readtable("3or21CascadeSDM_DataSet.csv");
data = table2array(table3or(2:end, :));

figure;
scatter3(data(:,1), data(:,2), data(:,3), 10, 'filled');
xlabel('SNR');
ylabel('Bw');
zlabel('Power');
title('3nd Order 2-1 Cascade SC SDM DataSet');

set(gca, 'YScale','log');