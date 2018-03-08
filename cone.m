function [ x ] = cone( p, q, lambda)
%PARETO Checks dominance

x = false;
if (nargin < 3)
    lambda = 0.2;
end

%p = -w(1)*[1;lamda]-w(2)*[lambda;1];
%q-p must belong to the cone above

c=q-p; %we calculate the point in relation to the origin

if (c(1)<=lambda*c(2))
    if (c(2)<=lambda*c(1))
        x=true;
    end    
end

end

