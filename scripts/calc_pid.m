% Skrypt do obliczania offline dyskretnych nastawów PID na podstawie danych z eksperymentu i zapisem do pliku jako kod ST.
clc; clear;

% --- KONFIGURACJA ---
Tp = 4; % Czas próbkowania (Sampling time)

% Nastawy dla PID 1
K1  = 0.5;
Ti1 = 35;
Td1 = 3;

% Nastawy dla PID 2
K2  = 0.5;
Ti2 = 35;
Td2 = 3;


% --- OBLICZENIA I GENEROWANIE TEKSTU ---


% Definicja wzorów
calc_r0 = @(K, Ti, Td) K * (1 + Tp/(2*Ti) + Td/Tp);
calc_r1 = @(K, Ti, Td) K * ((Tp/(2*Ti)) - (2*Td/Tp) - 1);
calc_r2 = @(K, Ti, Td) K * Td/Tp;


% Wyświetlenie wyników dla PID 1
fprintf('// --- Nastawy PID 1 ---\n');
fprintf('r0_PID1 := %.5f;\n', calc_r0(K1, Ti1, Td1));
fprintf('r1_PID1 := %.5f;\n', calc_r1(K1, Ti1, Td1));
fprintf('r2_PID1 := %.5f;\n', calc_r2(K1, Ti1, Td1));

fprintf('\n'); % Pusta linia dla odstępu

% Wyświetlenie wyników dla PID 2
fprintf('// --- Nastawy PID 2 ---\n');
fprintf('r0_PID2 := %.5f;\n', calc_r0(K2, Ti2, Td2));
fprintf('r1_PID2 := %.5f;\n', calc_r1(K2, Ti2, Td2));
fprintf('r2_PID2 := %.5f;\n', calc_r2(K2, Ti2, Td2));
