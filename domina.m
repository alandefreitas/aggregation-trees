function x = domina( a, b, dominance, parameter )
%Calculates the dominance according to the chosen relation

if (nargin<3)
    dominance = 1;
end

if dominance == 2
    if (nargin < 4)
        importance = 1:size(p,2);
    else
        importance=parameter;
    end    
elseif dominance == 3
    if nargin < 4
        lambda = linspace(1,0,length(p));
    else
        lambda=parameter;
    end    
elseif dominance == 5
    if nargin < 4
        lambda = 0.2;
    else
        lambda=parameter;
    end    
elseif dominance == 6
    if nargin < 4
        epsilon = 5;
    else
        epsilon=parameter;
    end    
end


switch dominance
    case 1
        x = pareto(a,b);
    case 2
        x = lexicographic(a,b,importance);
    case 3
        x = extrema(a,b, lambda);
    case 4
        x = maxdom(a,b);
    case 5
        x = cone(a,b,lambda);
    case 6
        x = pareto(a+epsilon,b);
    case 7
        x = lorenz(a,b);
    otherwise
        error('Invalid dominance');
end

end

