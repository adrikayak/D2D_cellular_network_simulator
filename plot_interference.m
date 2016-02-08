function [] = plot_interference( Interference_total, Interference_D2D, Interference_BS, string )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
figure
subplot(311)
plot(0:length(Interference_total)-1, 10*log10(Interference_total),'r', 'linewidth',2)
grid on
title(strcat('Network users mean interference level in ', string, ' environment'))
xlabel('Iteration')
ylabel('dBm')

subplot(312)
plot(0:length(Interference_D2D)-1, 10*log10(Interference_D2D),'g', 'linewidth',2)
grid on
title(strcat('D2D users mean interference level in ', string, ' environment'))
xlabel('Iteration')
ylabel('dBm')

subplot(313)
plot(0:length(Interference_BS)-1, 10*log10(Interference_BS),'b', 'linewidth',2)
grid on
title(strcat('BS users mean interference level in ', string, ' environment'))
xlabel('Iteration')
ylabel('dBm')

end

