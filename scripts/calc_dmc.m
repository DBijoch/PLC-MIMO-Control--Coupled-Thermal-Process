% Skrypt do obliczania offline macierzy DMC a podstawie danych z eksperymentu i zapisem do pliku jako kod ST.
load('data/SS.mat');
SS = SS(1:4:end, :, :);
D = size(SS, 1);
N = 20;
Nu = 5;
nu = 2;
ny = 2;

psi_vec = ones(ny*N, 1);
Psi = diag(psi_vec);

lambda_vec = ones(Nu*nu, 1)*3;
Lambda = diag(lambda_vec);

M_tensor = zeros(N, Nu, ny, nu);
for i = 1:N
    for j = 1:Nu
        if i < j
            M_tensor(i, j, :, :) = zeros(ny, nu);
        else
            M_tensor(i, j, :, :) = SS(i - j + 1, :, :);
        end
    end
end


M_perm = permute(M_tensor, [3, 1, 4, 2]); 
M = reshape(M_perm, ny*N, nu*Nu);

K = (M'*Psi*M + Lambda)\(M'*Psi);


K1 = K(1:nu, :); 

% Ke = suma(K_{1,p}) dla p=1..N. Każdy K_{1,p} ma wymiar nu x ny.
Ke = zeros(nu, ny);
for p = 1:N
    % Wyciągamy blok odpowiadający p-temu momentowi predykcji
    idx_start = (p-1)*ny + 1;
    idx_end   = p*ny;
    K1_p = K1(:, idx_start:idx_end);
    Ke = Ke + K1_p;
end

% B. Obliczenie macierzy Ku_i
% Potrzebujemy macierzy Mp. Zamiast budować wielką macierz Mp, 
% obliczymy Ku_i iteracyjnie dla każdego i = 1...(D-1).
% Ku_i = K1 * Mp_i (gdzie Mp_i to i-ta kolumna blokowa macierzy Mp)

Ku = cell(D-1, 1);

for i = 1:D-1
    % Budujemy i-tą kolumnę blokową macierzy Mp (wymiar ny*N x nu)
    Mp_i = zeros(ny*N, nu);
    
    % S_i (czyli S dla chwili i)
    S_i = squeeze(SS(i, :, :)); % ny x nu
    
    for p = 1:N
        % Indeksy wierszy w Mp_i
        idx_row_start = (p-1)*ny + 1;
        idx_row_end   = p*ny;
        
        % Pobranie S_{p+i} (z zabezpieczeniem, jeśli p+i > D to bierzemy S_D)
        if (p + i) > D
            S_future = squeeze(SS(D, :, :));
        else
            S_future = squeeze(SS(p + i, :, :));
        end
        
        % Wstawienie różnicy do kolumny Mp
        Mp_i(idx_row_start:idx_row_end, :) = S_future - S_i;
    end
    
    % Obliczenie Ku
    Ku{i} = K1 * Mp_i; % Wynik to macierz nu x nu
end

fid = fopen('dmc_params.txt', 'w');
% 
fprintf(fid, 'Ke11 := %.6f;\n', Ke(1,1));
fprintf(fid, 'Ke12 := %.6f;\n', Ke(1,2));
fprintf(fid, 'Ke21 := %.6f;\n', Ke(2,1));
fprintf(fid, 'Ke22 := %.6f;\n', Ke(2,2));
% fprintf(fid, 'Ku := [');
for i = 1:D-1
    fprintf(fid, 'Ku11[%d] := %.6f; ', i-1, Ku{i}(1,1));
end
fprintf(fid, '\n');
for i = 1:D-1
    fprintf(fid, 'Ku12[%d] := %.6f; ', i-1, Ku{i}(1,2));
end
fprintf(fid, '\n');
for i = 1:D-1
    fprintf(fid, 'Ku21[%d] := %.6f; ', i-1, Ku{i}(2,1));
end
fprintf(fid, '\n');
for i = 1:D-1
    fprintf(fid, 'Ku22[%d] := %.6f; ', i-1, Ku{i}(2,2));
end
fprintf(fid, '\n');
fclose(fid);