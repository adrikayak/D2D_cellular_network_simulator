function [ Pr, Pt_users ] = update( Pr, Pt_users, PL , Alloc, Pt_D2D, N, M, PL_users_BS_dB, S_BS )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

index_1 = find(Alloc == 1);
length(index_1)
index_2 = find(Alloc == 2);

for i = 1:(N+M)
    if Alloc(i) == 1
        Pt_users(i) = Pt_D2D;
        Pr(i,1:N) = PL(i,1:N) * Pt_users(i); 
        Pr(i,index_2) = 0;
    else
        if i > N
            Pt_users(i) = 10^((S_BS - PL_users_BS_dB(i))/10);
        else
            Pt_users(i) = Pt_D2D;
        end
        Pr(i,:) = PL(i,:) * Pt_users(i);
        Pr(i,index_1) = 0;
    end
end
end