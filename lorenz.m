function [ y ] = lorenz( p, q)
%PARETO Checks for dominance

Lp = sort(p);
Lq = sort(q);
for i=2:size(p)
    Lp(i) = Lp(i) + Lp(i-1);
    Lq(i) = Lq(i) + Lq(i-1);
end
y = pareto(Lp,Lq);

end

