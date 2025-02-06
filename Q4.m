clc;clear;close all; 
k = linspace(0 ,1000,1000);
u = sin((2*pi*k)/200);
g = 0.6*sin(pi*u) + 0.3*sin(pi*3*u) + 0.1*sin(pi*5*u);
y = zeros(size(k));
for i=2:1000
    y(i,1) = 0.3*y(i-1,1)+0.6*y(i-2,1)+u(i,1);
end
plot(k,y,'o');
