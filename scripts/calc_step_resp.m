% Skrypt do obliczania odpowiedzi skokowej dla wszystkich torów sterowania oraz  przygotowania macierzy SS do dalszych obliczeń.
load('data/step_resp_u1_28_48.mat')
u1_new1 = u1(21:400);
u2_new1 = u2(21:400);
y1_new1 = y1(21:400);
y2_new1 = y2(21:400);

load('data/step_resp_u2_33_53.mat')

u1_new2 = u1(6:385);
u2_new2 = u2(6:385);
y1_new2 = y1(6:385);
y2_new2 = y2(6:385);

du = 200;

SS = zeros(385-5, 2, 2);


SS(:, 1, 1) = (y1_new1-y1_new1(1))/du;
SS(:, 1, 2) = (y2_new1-y2_new1(1))/du;
SS(:, 2, 1) = (y1_new2-y1_new2(1))/du;
SS(:, 2, 2) = (y2_new2-y2_new2(1))/du;

SS_new = SS(1:4:end, :, :);

stairs(SS_new(:, 1, 1));
figure;
stairs(SS_new(:, 1, 2));
figure;
stairs(SS_new(:, 2, 1));
figure;
stairs(SS_new(:, 2, 2));

save('SS');



