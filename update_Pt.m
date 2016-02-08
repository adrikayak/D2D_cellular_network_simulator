function [ Pt_users ] = update_Pt( Pt_users, Pt_D2D, N, M, PL_users_BS_dB, S_BS )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

max_power = 20; %maximum transmission power of BS users in dBm 

for i = 1:(N+M)
    if i <= N
        Pt_users(i) = Pt_D2D;
    else
        Pt_users(i) = 10^((S_BS - PL_users_BS_dB(i))/10)/1e3;
        if Pt_users(i) > 10^(max_power/10)/1e3
            Pt_users(i) = 10^(max_power/10)/1e3;
        end
    end
end
end