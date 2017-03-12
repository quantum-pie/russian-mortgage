function [ mtp ] = total_duration( mp, p, ipp, tp, ops, cdf, pr )
% Function to calculate chained mortgage total duration in months (mtp). 
% Chained procedure consists of (ops) operations and goes as follows:
% - first operation with price (pr(1)) is carried out with (ipp) initial
% payment.
% - now you sell first flat for (pr(1)) price and use this money as initial
% payment for second operation that costs (pr(2)) and so on.
% - last operation costs target price (tp).
% We assume that target price and initial payment for first operation (ipp)
% are constant and other (ops - 1) prices are variables that used to 
% minimize total payment duration.
% Other arguments are:
% mp - montly annuity payment in rubles 
% p - annual interest rate in percents
% cdf - name of function to calculate duration of one operation

[~, examples] = size(pr);
mtp = zeros(examples, 1);

for k = 1:examples
    if ops == 1
        % only one operation for total price, no chaining
        % in this case result does not depend on prices (pr), because in fact 
        % pr is scalar that equal to target price (tp)
        mtp(k) = feval(cdf, tp, mp, p, tp * ipp / 100);
    else
        prr = pr(:, k);
        
        % first operation 
        mtp(k) = feval(cdf, prr(1), mp, p, prr(1) * ipp / 100);

        % intermediate operations
        for i = 2:ops - 1
            mtp(k) = mtp(k) + feval(cdf, prr(i), mp, p, prr(i - 1));
        end

        % final operation
        mtp(k) = mtp(k) + feval(cdf, tp, mp, p, prr(ops - 1)); 
    end    
end


end

