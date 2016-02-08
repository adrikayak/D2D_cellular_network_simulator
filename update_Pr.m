function [ Pr ] = update_Pr( Pr, PL , Alloc, N, M, Pt_users )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

index_1 = find(Alloc == 1);
index_2 = find(Alloc == 2);

for i = 1:(N+M)
    if Alloc(i) == 1
        Pr(i,index_1) = PL(i,index_1) * Pt_users(i); 
        Pr(i,index_2) = 0;
    else
        Pr(i,index_2) = PL(i,index_2) * Pt_users(i);
        Pr(i,index_1) = 0;
    end
end
end