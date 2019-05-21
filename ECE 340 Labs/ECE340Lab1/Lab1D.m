clear;

%y[k] = x[k] + a*y[k-1];

%        a = 0.5      a = 2.0
%y[0] |     1     |      1      |
%y[1] |    1.5    |      3      |
%y[2] |   1.75    |      7      |
%y[3] |   1.875   |      15     |
%y[4] |  1.9375   |      31     |
a = [0.5, 2];
x = ones(50, 1);

y1 = sysresp(x, a(1));
y2 = sysresp(x, a(2));

subplot(2,2,1);
g = stem(y1);
title('a = 0.5');
ylabel('y1');
xlabel('k');

subplot(2,2,2);
g = stem(y2);
title('a = 2.0');
xlabel('k');
ylabel('y2');
%Any value of (a < 1) will produce a BIBO stable system.
%However as we approach 1 it will take more samples before we see the
%system tapering on the graph.
y3 = sysresp(x, 0.75);

subplot(2,2,3);
g = stem(y3);
title('a = 0.75');
ylabel('y3');
xlabel('k');