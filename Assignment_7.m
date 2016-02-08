
%% Initial variables definition
clear all
close all

r = 2;  %Two channels: Channel 1 = D2D, Channel 2 = Cellular network

%Urban environment 
b_urban = 6;  %Pathloss exponent
sdb_urban = 12;  %Fading  standard deviation

lambda_D2D_urban = 150;    %Arriving rate for D2D users
lambda_BS_urban = 150;    %Arriving rate for Cellular users

%Suburban environment 
b_suburban = 3.5;  %Pathloss exponent
sdb_suburban = 9;  %Fading  standard deviation

lambda_D2D_suburban = 60;    %Arriving rate for D2D users
lambda_BS_suburban = 60;    %Arriving rate for Cellular users

%Rural environment 
b_rural = 2;  %Pathloss exponent
sdb_rural = 6;  %Fading  standard deviation

lambda_D2D_rural = 20;    %Arriving rate for D2D users
lambda_BS_rural = 20;    %Arriving rate for Cellular users

%Powers and BS sensitivity
Pt_BS_dB = 0;  %BS transmission power in dBm
Pt_BS = 10^(Pt_BS_dB/10)/1e3; %%BS transmission power in W

Pt_D2D_dB = 30; %%D2D users transmission power in dBm
Pt_D2D = 10^(Pt_D2D_dB/10)/1e3; %%D2D transmission power in linear scale in W

S_BS = -100; %BS sensitivity in dBm

%% Calling GADIA algorithm
for i = 1:1
    iter = i
    
[ Interference_total_urban(i,:), Interference_D2D_urban(i,:), Interference_BS_urban(i,:), Interference_total_random_urban(i), Interference_D2D_random_urban(i),...
    Interference_BS_random_urban(i)] = GADIA( lambda_BS_urban, lambda_D2D_urban, b_urban, sdb_urban, r, Pt_D2D, S_BS, ' urban');

[ Interference_total_suburban(i,:), Interference_D2D_suburban(i,:), Interference_BS_suburban(i,:), Interference_total_random_suburban(i), Interference_D2D_random_suburban(i), ...
    Interference_BS_random_suburban(i)] = GADIA( lambda_BS_suburban, lambda_D2D_suburban, b_suburban, sdb_suburban, r, Pt_D2D, S_BS,' suburban' );

[ Interference_total_rural(i,:), Interference_D2D_rural(i,:), Interference_BS_rural(i,:), Interference_total_random_rural(i), Interference_D2D_random_rural(i), ...
    Interference_BS_random_rural(i)] = GADIA( lambda_BS_rural, lambda_D2D_rural, b_rural, sdb_rural, r, Pt_D2D, S_BS, ' rural');

end


%% Plotting mean interference
plot_interference(Interference_total_urban, Interference_D2D_urban, Interference_BS_urban, ' urban')
plot_interference(Interference_total_suburban, Interference_D2D_suburban, Interference_BS_suburban, ' suburban')
plot_interference(Interference_total_rural, Interference_D2D_rural, Interference_BS_rural, ' rural')



%% Plot bar plot
y = [mean(Interference_D2D_urban(:,1)), mean(Interference_D2D_random_urban), mean(Interference_D2D_urban(:,end));...
    mean(Interference_D2D_suburban(:,1)), mean(Interference_D2D_random_suburban), mean(Interference_D2D_suburban(:,end));...
    mean(Interference_D2D_rural(:,1)), mean(Interference_D2D_random_rural), mean(Interference_D2D_rural(:,end))];

y = 10*log10(y);

figure

bar(y)

set(gca,'XTickLabel',{'Urban environment', 'Suburban environment', 'Rural environment'})

title('Mean D2D user interference levels for different environments')
ylabel('dBm')
legend('No frequency allocation','Random frequency allocation','GADIA frequency allocation')














