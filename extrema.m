function [ y ] = extrema( p, q, lambda)
%PARETO Checks for dominance

y = false;

if (nargin<3)
    lambda = linspace(1,0,length(p));
end

if (sum(lambda.*p)>sum(lambda.*q))
        y=true;
end

end

