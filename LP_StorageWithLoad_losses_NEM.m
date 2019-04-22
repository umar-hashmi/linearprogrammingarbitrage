%% Energy Arbitrage with linear programming
% Code Author: Md Umar Hashmi
% Date: 22 April 2019
% Location: LINCs Paris

% Cite: Hashmi, M.U., Mukhopadhyay, A., Bu\v{s}i\'c, A., and Elias, J. 
% {Optimal Storage Arbitrage under Net Metering Policies using Linear Programming.}

% This code considers storage operation with load and it considers (a) charging and
% discharging losses (b) net-metering compensation (according to which the
% selling price could be at best equal to buying price of electricity (c)
% variation of load and renewable generation

clear
close all
clc

load('Load_price_data.mat');        % Load electricity price and (inelastic load - renewable generation) data
N=length(real);                     % Length of horizon in number of samples
% Unit of electricity price cents per kWh
% Unit of load is kWh

% battery parameters
e_ch=0.95;                          % Charging efficiency
e_dis =0.95;                        % Discharging efficiency 
del_max = 4000;                     % Maximum charging rate
del_min = -del_max;                 % Minimum discharging rate
b_0 = 1000;                         % Initial battery capacity
b_max = 2000;                       % Maximum battery capacity
b_min = 200;                        % Minimum permissible battery capacity
h=0.25;                             % Sampling time

kappa = 1;                          % the ratio of selling price and buying price   

tic


K1 = -real.*load;
K2 = -kappa*real.*load;

real_buy = real/e_ch;
real_sell = kappa*real*e_dis;
real_interme = real*e_dis;
real_interme_negload = kappa*real/e_ch;

A_buy = diag(real_buy);
A_sell = diag(real_sell);
A_interm = diag(real_interme);
A_intermnegload = diag(real_interme_negload);
A_minus = -1*eye(N);
A_zero = zeros(N);

% LP matrix formulation
A = [A_buy A_minus; A_interm A_minus; A_intermnegload A_minus; A_sell A_minus; tril(ones(N,N),-1) + eye(N)  A_zero; -tril(ones(N,N),-1) - eye(N)  A_zero];
b=[K1; K1; K2; K2;(b_max-b_0)*ones(N,1); (b_0-b_min)*ones(N,1)];

lb=[del_min*h*ones(N,1); -1000000*ones(N,1)];
ub=[del_max*h*ones(N,1); 1000000*ones(N,1)];

Aeq=[];
beq=[];
f=[zeros(N,1); ones(N,1)];

x_state = linprog(f,A,b,Aeq,beq,lb,ub);
x= x_state(1:N);

cost_of_consumption_nominal = sum(real'*subplus(load)-kappa*real'*subplus(-load))/1000

x_ch = max(0,x);
x_ds = -min(0,x);
lhouse = load+x_ch/e_ch - x_ds*e_dis;

profit_only_arbitrage = cost_of_consumption_nominal- sum(real'*subplus(lhouse)-kappa*real'*subplus(-lhouse))/1000
toc

x_adj= x/b_max;