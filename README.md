# Optimal Energy Arbitrage using Linear Programming
Code repo for our 2019 paper: Optimal Storage Arbitrage under Net Metering Policies using Linear Programming

Authors: Md Umar Hashmi, Arpan Mukhopadhyay, Ana Bu\v{s}i\'c, and Jocelyne Elias

INRIA, DI ENS, Ecole Normale Sup\'erieure, CNRS, PSL Research University, Paris, France

Contact: umar.hashmi123@gmail.com

## Introduction
We formulate energy storage arbitrage problem using linear programming. 
The LP formulation is possible due to piecewise linear convex cost functions.
In this formulation we consider: (a) net-metering compensation (with selling price at best equal to buying price) i.e. $\kappa_i \in [0,1]$, (b) inelastic load, (c) consumer renewable generation, (d) storage charging and discharging losses, (e) storage ramping constraint and (f) storage capacity constraint. 
Using numerical results we perform sensitivity analysis of energy storage batteries for varying ramp rates and varying ratio of selling and buying price of electricity.

![alt text](https://www.dropbox.com/s/zn9dxh9ifv9t6rv/lpcost.jpg)



## Code Dependencies
All code are implemented in MATLAB.

