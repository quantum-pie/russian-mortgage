%% Input parameters

% annual interest rate in percents
year_percent = 11;

% target price in rubles
target_price = 6000000;

% family month income in rubles
month_income = 150000;

% percent of income to pay credit
payment_percent = 40;

% initial payment percent for first operation
initial_payment_percent = 20;

% month payment in rubles
month_pay = month_income * payment_percent / 100;

% number of operations
operations = 1;

%% Calculations

% total payment duration as function of first (operations - 1) operations
% prices (last operation price is fixed to target_price)
func = @(prices) total_duration(month_pay, year_percent, initial_payment_percent, target_price, operations, 'credit_duration', prices);

if operations > 1
    % optimization options
    options = optimset('FunValCheck', 'on', 'TolX', 1e-12);

    % upper bound for minimum point
    upper_bound = ones(operations - 1, 1) * target_price;

    % lower bound for minimum point
    lower_bound = zeros(operations - 1, 1);

    % initial minimum guess
    attempts = 0;
    while true
        initial_guess = rand(operations - 1, 1) * target_price;
        if(~isinf(func(initial_guess)))
            break;
        end
        attempts = attempts + 1;
        if attempts == 100
            disp('Incorrent input');
            return;
        end
    end

    % linear inequality constraint matrix A
    Aineq = eye(operations - 1);
    Aineq(operations:operations:end) = -1;

    % linear inequality constraints vector b
    bineq = zeros(operations - 1, 1);
    bineq(end) = target_price;

    % linear constraints are simple:
    % prices(i) >= prices(i - 1)
    % prices(end) <= target_price

    % find minumum
    optimum = fmincon(func, initial_guess, Aineq, bineq, [], [], lower_bound, upper_bound, [], options);
    optimum = [optimum; target_price];
else
    optimum = target_price;
end

% calculate minimum duration in months
min_duration = func(optimum);

%% Graphic output

optimum = optimum / 1e6;

disp(['Operations prices are ', mat2str(optimum), ' millions'])
disp(['Duration is ', num2str(min_duration / 12), ' years'])

if operations == 2
    delta_graphic = target_price / 1000;
    x = 0:delta_graphic:target_price;
    y = func(x);
    plot(x / 1e6, y)
    hold on
    plot(optimum(1), min_duration, 'rv')
    txt = ['\leftarrow Min duration is ', num2str(min_duration / 12), ' years'];
    text(optimum(1), min_duration, txt)
    grid on
    xlabel('First op price, millions')
    ylabel('Duration in months')
    
    hold off
    
elseif operations == 3    
    delta_graphic = target_price / 50;
    x = 0:delta_graphic:target_price;
    y = 0:delta_graphic:target_price;
    [X, Y] = meshgrid(x, y);
    
    Z = tril(reshape(func([X(:)'; Y(:)']), size(X)));
    Z(isinf(Z)) = 0;
    
    sz = 10 * double(Z > 0) + eps;
    scatter3(X(:) / 1e6, Y(:) / 1e6, Z(:), sz(:), 'filled')
    hold on
    plot3(optimum(1), optimum(2), min_duration, 'rv')
    txt = ['\leftarrow Min duration is ', num2str(min_duration / 12), ' years'];
    text(optimum(1), optimum(2), min_duration, txt)
    xlabel('First op price, millions')
    ylabel('Second op price, millions')
    zlabel('Duration in months')
    
    hold off
    
elseif operations == 4 
    delta_graphic = target_price / 10;
    x = 0:delta_graphic:target_price;
    y = 0:delta_graphic:target_price; 
    z = 0:delta_graphic:target_price;
    [X, Y, Z] = meshgrid(x, y, z);    
    
    S = reshape(func([X(:)'; Y(:)'; Z(:)']), size(X));
    
    % magic - lower pyramid of 3d matrix
    for j = 1:length(z)
        S(:, :, j) = tril(S(:, :, j));
        S(j + 1 : end, :, j) = 0;
    end
    
    S(isinf(S)) = 0;
    C = log(S);
    S = S .^ 2;
    S = 100 * S / max(S(:)) + eps;
    scatter3(X(:) / 1e6, Y(:) / 1e6, Z(:) / 1e6, S(:), C(:), 'filled')
    hold on
    plot3(optimum(1), optimum(2), optimum(3), 'rv')
    colormap('Jet')
    c = colorbar;
    c.Label.String = 'Log of duration in months';
    txt = ['\leftarrow Min duration is ', num2str(min_duration / 12), ' years'];
    text(optimum(1), optimum(2), optimum(3), txt)
    xlabel('First op price, millions')
    ylabel('Second op price, millions')
    zlabel('Third op price, millions')
    
    hold off
end