clc;clear;close all;
data = importdata("ballbeam.dat");
output = data(:,2);
input = zeros(size(output));
for i=2:length(output)-1
    input(i) = output(i-1);
end
data = [input data];
anfisedit