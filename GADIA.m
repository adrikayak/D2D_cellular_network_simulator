function [ Interference_total, Interference_D2D, Interference_BS, Interference_total_random, Interference_D2D_random, Interference_BS_random ] = GADIA( lambda_BS, lambda_D2D, b, sdb, r, Pt_D2D, S_BS, string)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
max_iter = 20;
tol = 1e-9;
%% Users placement within the cell

%PPP for BS users
M = poissrnd(lambda_BS);   %Number of BS users
Pointsx = round(rand(1,M)*1000);
Pointsy = round(rand(1,M)*1000);
BSusers = [Pointsx; Pointsy];
BS = [500;500];

%PPP for D2D users
N = poissrnd(lambda_D2D);   %Number of D2D users
d2dPointsx = round(rand(1,N)*1000);
d2dPointsy = round(rand(1,N)*1000);
D2Dusers = [d2dPointsx; d2dPointsy];

%% Distance calculation

dist_D2Dusers = distance(N, N, D2Dusers, D2Dusers);   %D2Dusers - D2Dusers

dist_D2Dusers_BSusers = distance(N, M, D2Dusers, BSusers);   %D2Dusers - BSusers

dist_BSusers = distance(M ,M, BSusers, BSusers);   %D2Dusers - BSuser

dist_D2Dusers_BS = distance(1, N , BS, D2Dusers);   %D2Dusers - BS

dist_BSusers_BS = distance(1, M , BS, BSusers);   %BSusers - BS

dist_users_BS = [dist_D2Dusers_BS, dist_BSusers_BS];

dist = [dist_D2Dusers dist_D2Dusers_BSusers ; dist_D2Dusers_BSusers' dist_BSusers];

%% Ploting the first approach
% figure
% scatter(BS(1),BS(2),'or','fill') %BS
% hold on
% scatter(Pointsx,Pointsy,'sb','fill') %BS users
% scatter(d2dPointsx,d2dPointsy,'^g','fill') %D2D users
% grid on
% title(strcat('Users locations map for', string, ' environment'))
% legend('BS', 'BS users', 'D2D users')

%% Calculating pathloss matrix

PL = dist.^(-b) .* 10.^(0.1 * sdb * randn((N+M),(N+M)));
ind = isinf(PL); 
PL(ind) = 0;

PL_users_BS = dist_users_BS.^(-b) .* 10.^(0.1 * sdb * randn(1,(N+M)));

PL_users_BS_dB = 10 * log10(PL_users_BS);

%% Initialize interference matrix 

Alloc_GD   = [ones(1,N), r*ones(1,M)];  %Initial channel allocation (all D2D users on channel 1 and all BS users on channel 2)
Alloc_random = [round(rand(1,N)+1), r*ones(1,M)];   %Initial random channel allocation for D2D users

Pt_users = update_Pt(zeros(1,(N+M)), Pt_D2D, N, M, PL_users_BS_dB, S_BS);

Pr = zeros(size(PL));

[Pr_random] = update_Pr(Pr, PL , Alloc_random, N, M, Pt_users);
[Pr] = update_Pr(Pr, PL , Alloc_GD, N, M, Pt_users);


%% GADIA implementation

Alloc_temp = Alloc_GD;

DONE = 0;
cnt  = 1; 

Interference_total(cnt) = sum(sum(Pr))/(N+M);
Interference_D2D(cnt) = sum(sum(Pr(:,1:N)))/N;
Interference_BS(cnt) = sum(sum(Pr(:,N+1:end)))/M;

while(~DONE && cnt <= (max_iter - 1))
    cnt = cnt + 1;
  
    for ii = 1 : N % over all D2D users 
        
        Ii_channel_temp = Inf;         
        for channel = 1 : r  % over all channels 
            
            % find interfering D2D users on the considered channel 
            c = find(Alloc_temp == channel);    %Find users using the channel "channel" 
            
            if (intersect(c,ii))    %Is user "ii" located among those using channel "channel"?
                c = setxor(c,ii); %If yes, eliminate user "ii" from "c"
            end
            
            if (~isempty(c))    %Is "c" empty? "c" contains users' indices which operate at channel "channel"
                Ii_c = sum(Pr(c,ii));   %If NO, sum up the interference of all "c" users over "ii" user
            else Ii_c = 0; %If YES, the interference that user "ii" suffers is 0.
            end
            
            % decide whether to change channel or not 
            if (Ii_c <= Ii_channel_temp)
                Alloc_temp(ii) = channel; 
                Ii_channel_temp = Ii_c;
            end 
        end
        [Pr] = update_Pr(Pr, PL , Alloc_GD, N, M, Pt_users);
    end
    
    Interference_total(cnt) = sum(sum(Pr))/(N+M);
    Interference_D2D(cnt) = sum(sum(Pr(:,1:N)))/N;
    Interference_BS(cnt) = sum(sum(Pr(:,N+1:end)))/M;
     
    if(cnt > 2)
        flag = (abs(sum(sum(Pr(:,1:N)))/N - Interference_D2D(cnt-2)) < tol && sum(sum(Pr(:,1:N)))/N < Interference_D2D(cnt-1));
    else
        flag = 0;
    end
    
%     if (sum(Alloc_temp - Alloc_GD) == 0)
%         disp('No realocations')
%     end
%     if(flag == 1)
%         disp(strcat('Flag = 1 in ',string))
%         plot_interference(Interference_total, Interference_D2D, Interference_BS, string)
%         pause  
%     end      

    if (sum(Alloc_temp - Alloc_GD) == 0 || flag ) % no channel re-allocations
        DONE = 1;
    else
        Alloc_GD = Alloc_temp;
    end
    
    
end


Interference_total(cnt+1) = sum(sum(Pr))/(N+M);
Interference_D2D(cnt+1) = sum(sum(Pr(:,1:N)))/N;
Interference_BS(cnt+1) = sum(sum(Pr(:,N+1:end)))/M;

diff = max_iter - cnt + 1;

if diff > 0
    Interference_total = [Interference_total, Interference_total(end) * ones(1,diff)];
end

if diff > 0
    Interference_D2D = [Interference_D2D, Interference_D2D(end) * ones(1, diff)];
end

if diff > 0
    Interference_BS = [Interference_BS, Interference_BS(end) * ones(1, diff)];
end

if Interference_D2D(1) < Interference_D2D(end)
    disp(strcat('Initial interference higher than last in ',string))
%     plot_interference(Interference_total, Interference_D2D, Interference_BS, string)
%     pause    
end

Interference_total_random = sum(sum(Pr_random))/(N+M);
Interference_D2D_random = sum(sum(Pr_random(:,1:N)))/N;
Interference_BS_random = sum(sum(Pr_random(:,N+1:end)))/M;

% Plot final map
figure
hold on
scatter(BS(1),BS(2),'or','fill')
scatter(D2Dusers(1,find(Alloc_temp(1:N) == 1)),D2Dusers(2,find(Alloc_temp(1:N) == 1)),'^g','fill')
scatter(D2Dusers(1,find(Alloc_temp(1:N) == 2)),D2Dusers(2,find(Alloc_temp(1:N) == 2)),'^c','fill')
scatter(BSusers(1,:),BSusers(2,:),'sb','fill')

title(strcat('Users locations map for', string, ' environment after GADIA'))
legend('BS','D2D users using band 1','D2D users using band 2','BS users','location','eastoutside')
end