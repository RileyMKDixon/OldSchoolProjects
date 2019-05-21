function y=sysresp(x, a)
%
% computes the output in response to an arbitrary input x[n], n=0,…N-1
% assume that the system has 0 initial conditions
% input:
% x: the input signal,
% a: the system parameter
% output:
% y: the output signal
N = length(x); % length of the vector
% initialization of the output signal
y = zeros(N, 1);
% the first element in y is y[0], the second is y[1], ...
% note that in Matlab, the vector index starts from 1 and must be a pos. integer
% so the output at time n (y[n]) is the (n+1)th element in the vector y
y(1) = x(1) + a * 0; %y(k) = 0 for values for k < 0;

for k = 2:N
    y(k) = x(k) + a * y(k-1);
end

return