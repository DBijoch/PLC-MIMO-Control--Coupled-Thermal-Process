%% Socket Communication do komunikacji z PLC. Skrypt służy do odbierania danych z PLC oraz ich wizualizacji w czasie rzeczywistym.
delete(instrfindall)
pause(2);

close all;
clear all; 
  
t = tcpip('192.168.127.250',4000, 'NetworkRole', 'client');

t.OutputBufferSize = 3000;
t.InputBufferSize = 3000;
 
fopen(t);
u1 = [];
u2 = [];
y1 = [];
y2 = [];
yz1 = [];
yz2 = [];
yzad1 = [];
yzad2 = [];

figure(1);
while (length(y1) < 10000)
    if (t.BytesAvailable ~= 0)
        temp = fscanf(t);
        disp(temp);
        eval(temp);
        u1 = [u1; U1];
        u2 = [u2; U2];
        y1 = [y1; Y1];
        y2 = [y2; Y2];
        yz1 = [yz1; YZ1];
        yz2 = [yz2; YZ2];
        yzad1 = [yzad1; YZad1];
        yzad2 = [yzad2; YZad2];
        
        subplot(2,1,1); plot(y1); hold on; plot(yzad1, '--'); hold off; legend('y1', 'yzad1', 'Location', 'southwest'); title('Wyj�cie'); xlabel('iteracja');
        subplot(2,1,2); stairs(u1); hold off; title('Sterowanie'); xlabel('iteracja');
        drawnow
    end
    pause(0.05);
end

fclose(t);
delete(t);
clear t;

