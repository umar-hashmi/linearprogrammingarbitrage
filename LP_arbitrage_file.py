# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np
from scipy.optimize import linprog
import scipy.io
import pandas as pd

# Load electricity price and (inelastic load - renewable generation) data
# Assuming that 'real' is the load_price_data
# Replace this with actual load_price_data if available
#load_price_data = np.loadtxt('Load_price_data.mat')

df = pd.read_csv(r'data.csv')
load = df[df.columns[0]]
real = df[df.columns[1]]

N = len(load)  # Length of horizon in number of samples

# Unit of electricity price cents per kWh
# Unit of load is kWh

# Battery parameters
e_ch = 0.95  # Charging efficiency
e_dis = 0.95  # Discharging efficiency
del_max = 4000  # Maximum charging rate
del_min = -del_max  # Minimum discharging rate
b_0 = 1000  # Initial battery capacity
b_max = 2000  # Maximum battery capacity
b_min = 200  # Minimum permissible battery capacity
h = 0.25  # Sampling time

kappa = 1  # the ratio of selling price and buying price

real_buy = real / e_ch
real_sell = kappa * real * e_dis

A_buy = np.diag(real_buy)
A_sell = np.diag(real_sell)
A_minus = -1 * np.eye(N)
A_zero = np.zeros((N, N))

# LP matrix formulation
A_upper = np.hstack((A_buy, A_minus))
A_lower = np.hstack((A_sell, A_minus))
A_eq1 = np.hstack((np.tril(np.ones((N, N)), -1) + np.eye(N), A_zero))
A_eq2 = np.hstack((-np.tril(np.ones((N, N)), -1) - np.eye(N), A_zero))

A = np.vstack((A_upper, A_lower, A_eq1, A_eq2))

b_upper = np.zeros(2 * N)
b_lower = (b_max - b_0) * np.ones(N)
b_eq = (b_0 - b_min) * np.ones(N)

b = np.concatenate((b_upper, b_lower, b_eq))

lb = np.hstack((del_min * h * np.ones(N), -100000 * np.ones(N)))
ub = np.hstack((del_max * h * np.ones(N), 100000 * np.ones(N)))

f = np.hstack((np.zeros(N), np.ones(N)))

# Solve the linear programming problem
res = linprog(c=f, A_ub=A, b_ub=b, bounds=list(zip(lb, ub)))

x_state = res.x[:N]
x = x_state

# Calculate profit from arbitrage
profit_only_arbitrage = np.sum(load * np.maximum(x, 0) / e_ch - kappa * load * np.maximum(-x, 0) * e_dis) / 1000

x_adj = x / b_max
