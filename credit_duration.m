function [ mtp ] = credit_duration(cs, mp, p, ip)
% Fucntion to calculate mortgage payment duration in months (mtp) from 
% total credit sum in rubles (cs), montly annuity payment in rubles (mp), 
% annual interest rate in percents (p) and initial payment in rubles (ip).
% Mortgage montly annuity payment formula is: 
% mp = cs * pp / (1 - (1 + pp)^(1 - mtp)) 
% where pp = p / 1200.
% Function result is achieved by solving this equation relative to mtp.

cs = cs - ip;
pp = p / 1200;
log_arg = (1 + pp) * mp / (mp - cs * pp);
log_base = 1 + pp;

if log_arg >= 0
    mtp = log(log_arg) / log(log_base);
else
    % If we cant pay it totally
    mtp = Inf;

end

