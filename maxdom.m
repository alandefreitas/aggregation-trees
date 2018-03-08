function [ y ] = maxdom( p, q)
%PARETO checks for dominance

y = false;
if (max(p)>max(q))
    y = true;
end

end

