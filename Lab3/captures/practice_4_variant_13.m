clear;
clc;
close all;
format short g;

%% 1. Матриці першої підсистеми
% Початкове рівняння:
% q'' + 2*q' - q = -2*u
% Стани: x1 = q, x2 = q'

A1 = [0  1;
      1 -2];

B1 = [0;
     -2];

C1 = [1 0];
D1 = 0;

S1 = ss(A1, B1, C1, D1);

%% 2. Матриці другої підсистеми
% Два входи та один вихід

A2 = [-1 2;
       3 2];

B2 = [1 -1;
      2  1];

C2 = [-2 4];
D2 = zeros(1, 2);

S2 = ss(A2, B2, C2, D2);

%% 3. Матриці третьої підсистеми
% Один вхід та два виходи

A3 = [1  2;
      3 -2];

B3 = [-4;
       1];

C3 = [5 -1;
      3  1];

D3 = zeros(2, 1);

S3 = ss(A3, B3, C3, D3);

%% 4. Керованість і спостережуваність підсистем

systems = {S1, S2, S3};

n = zeros(3, 1);
rankCtrb = zeros(3, 1);
rankObsv = zeros(3, 1);

for k = 1:3
    Sk = systems{k};

    % Кількість станів
    n(k) = size(Sk.A, 1);

    % Матриця керованості
    R = ctrb(Sk.A, Sk.B);

    % Матриця спостережуваності
    O = obsv(Sk.A, Sk.C);

    rankCtrb(k) = rank(R);
    rankObsv(k) = rank(O);

    fprintf('\n===== ПІДСИСТЕМА %d =====\n', k);

    disp('Матриця керованості:');
    disp(R);

    disp('Матриця спостережуваності:');
    disp(O);
end

Subsystem = (1:3)';
Controllable = (rankCtrb == n);
Observable = (rankObsv == n);

results = table(Subsystem, n, rankCtrb, rankObsv, ...
                Controllable, Observable);

disp(' ');
disp('Підсумки для окремих підсистем:');
disp(results);

%% 5. Об'єднання за структурною схемою 6
%
% Після append(S1, S2, S3) нумерація входів:
% u1 — вхід S1;
% u2 — перший вхід S2;
% u3 — другий вхід S2;
% u4 — вхід S3.
%
% Нумерація виходів:
% y1 — вихід S1;
% y2 — вихід S2;
% y3 — перший вихід S3;
% y4 — другий вихід S3.
%
% Внутрішні зв'язки схеми:
% u2 = y4;
% u4 = y1.
%
% Зовнішні входи:  u1, u3.
% Зовнішні виходи: y3, y2.

Sall = append(S1, S2, S3);

Q = [2 4;
     4 1];

inputs = [1 3];
outputs = [3 2];

% Зберігаємо всі початкові стани для їх дослідження
opts = connectOptions('Simplify', false);

S = connect(Sall, Q, inputs, outputs, opts);

%% 6. Матриці результуючої системи

[A, B, C, D] = ssdata(S);

disp(' ');
disp('===== РЕЗУЛЬТУЮЧА СИСТЕМА =====');

disp('Матриця A:');
disp(A);

disp('Матриця B:');
disp(B);

disp('Матриця C:');
disp(C);

disp('Матриця D:');
disp(D);

%% 7. Керованість і спостережуваність з'єднання

R = ctrb(A, B);
O = obsv(A, C);

nTotal = size(A, 1);
rTotal = rank(R);
oTotal = rank(O);

disp('Матриця керованості з''єднання:');
disp(R);

disp('Матриця спостережуваності з''єднання:');
disp(O);

fprintf('\nКількість станів: %d\n', nTotal);
fprintf('Ранг матриці керованості: %d\n', rTotal);
fprintf('Ранг матриці спостережуваності: %d\n', oTotal);

fprintf('Система повністю керована: %d\n', rTotal == nTotal);
fprintf('Система повністю спостережувана: %d\n', oTotal == nTotal);