clc
clear all
close all


f = fred;
startdate = '01/01/1994';
enddate = '01/01/2022';

CAN = fetch(f,'NGDPRSAXDCCAQ',startdate,enddate);
JPN = fetch(f,'JPNRGDPEXP',startdate,enddate);
can = log(CAN.Data(:,2));
jpn = log(JPN.Data(:,2));
q = CAN.Data(:,1);
T = size(can,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauCANGDP = A\can;
tauJPNGDP = A\jpn;

% detrended GDP
cantilde = can-tauCANGDP;
jpntilde = jpn-tauJPNGDP;

% plot detrended GDP
dates = 1994:1/4:2022.1/4; zerovec = zeros(size(can));
figure
title('Detrended log(real GDP) 1994Q1-2022Q4'); hold on
plot(q, cantilde,'b', q, jpntilde,'r')
legend('Canada', 'Japan', 'Location', 'southwest');
datetick('x', 'yyyy-qq')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
cansd = std(cantilde)*100;
jpnsd = std(jpntilde)*100;
corrcanjpn = corrcoef(cantilde(1:T),jpntilde(1:T)); corrcanjpn = corrcanjpn(1,2);

disp(['Percent standard deviation of detrended log real GDP: ', num2str(cansd),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP: ', num2str(jpnsd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corrcanjpn),'.']);




