%% Energy Arbitrage with linear programming
% Code Author: Md Umar Hashmi
% Date: 22 April 2019
% Location: LINCs Paris

% Cite: Hashmi, M.U., Mukhopadhyay, A., Bu\v{s}i\'c, A., and Elias, J. 
% {Optimal Storage Arbitrage under Net Metering Policies using Linear Programming.}

% This code considers only storage operation with (a) charging and
% discharging losses (b) net-metering compensation (according to which the
% selling price could be at best equal to buying price of electricity

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


real_buy = real/e_ch;
real_sell = kappa*real*e_dis;

A_buy = diag(real_buy);
A_sell = diag(real_sell);
A_minus = -1*eye(N);
A_zero = zeros(N);

tic
% LP matrix formulation
A = [A_buy A_minus; A_sell A_minus; tril(ones(N,N),-1) + eye(N)  A_zero; -tril(ones(N,N),-1) - eye(N)  A_zero];
b=[zeros(2*N,1);(b_max-b_0)*ones(N,1); (b_0-b_min)*ones(N,1)];

lb=[del_min*h*ones(N,1); -100000*ones(N,1)];
ub=[del_max*h*ones(N,1); 100000*ones(N,1)];

Aeq=[];
beq=[];
f=[zeros(N,1); ones(N,1)];

x_state = linprog(f,A,b,Aeq,beq,lb,ub);
toc
x= x_state(1:N);

profit_only_arbitrage =  sum(real'*subplus(x)/e_ch-kappa*real'*subplus(-x)*e_dis)/1000

x_adj= x/b_max;

