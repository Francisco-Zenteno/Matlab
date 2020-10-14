%{ 
    Modelización y simulación de procesos energéticos
    
    Proyecto de evaluación
    Modelado de conversor DC DC tipo BUCK converter
    
        Modelado, control y simulación con función de transferencia y
        variables de estado. 
    
    Elaborado por: Francisco José Pérez Zenteno
%}

%   Ejecutar primero archivo de Simulink para obtener los datos para
%   graficar

clc
% clear

%   Variables del sistema
vi  = 24;
R   = 11;
C   = 4e-6;
%L  = 58e-6;           %Valor crítico del inductor para este sistema
L   = 60e-6;            %Valor sobreestimado para trabajar en modo continuo 

%%  Graficas del circuito de simulink
plot(out.il_lazo_abierto.Time,out.il_lazo_abierto.Data,'LineWidth',1.5);
xlim([0 0.35e-3])
xlabel('Tiempo [s]')
title('Corriente del inductor en lazo abierto')
ylabel('Corriente del inductor [A]')
grid on 

figure
plot(out.vr_lazo_abierto.Time,out.vr_lazo_abierto.Data,'LineWidth',1.5);
xlim([0 0.35e-3])
xlabel('Tiempo [s]')
title('Voltaje de la carga en lazo abierto respuesta a PWM')
ylabel('Voltaje de la carga [V]')
grid on 

%%  MODELADO POR MEDIO DE VARIABLES DE ESTADO

A = [0 -1/L ; 1/C -1/(R*C)];
B = [vi/L ; 0];
C = [0 1];
D = 0;

%   Se crea el objeto de variables de estado
sys = ss(A,B,C,D);

%   Se obtienen los polos del sistema (eigenvalores)
E = eig(A);
isstable(sys);        %   Dice si el sistema es estable o no.
pzplot(sys,'g');     %   Dibuja los ceros y los polos del sistema

%   Se muestra su respuesta a un escalon
figure
plot(out.vr_lazo_abierto2.Time,out.vr_lazo_abierto2.Data,'LineWidth',1.5)
xlim([0 0.5e-3])
xlabel('Tiempo [s]')
title('Voltaje de la carga en lazo abierto respuesta a escalón')
ylabel('Voltaje de la carga [V]')
grid on

%   Se muestra la respuesta en frecuencia... bode
%bode = bodeplot(sys);
%setoptions(bode,'FreqUnits','Hz')

%%  MODELADO POR MEDIO DE FUNCIÓN DE TRASNFERENCIA 

%   Constantes para el PID (obtenidos con Tune de Simulink )
kp = 0.18964;
ki = 4746.3386;
kd = 1.6250e-6;
%tf = 4.4077e-8;               %Filtro pasa bajas para el control derivativo

%   Forma de realizar la función de transferencia a partir del Espacio
%   de Estados

[b,a] = ss2tf(A,B,C,D);
sys2   = tf(b,a);
stp2 = step(sys2);
stepinfo(sys2)

%   Forma manual de obtener la funcíon de trasnferencia
syms s;
[num, den] = numden(C * inv(eye(length(A))*s - A) * B);
%sys2 = tf(num,den)

%   Forma de implementar manualmente un PID
C = pid(kp,ki,kd);
sys2_pid = (sys2*C)/(1+sys2*C);
%figure;
%step(sys2_pid);
stepinfo(sys2_pid)

%   Gráfica de PID de simulink
figure
plot(out.vr_pid.Time,out.vr_pid.Data,'LineWidth',1.5);
xlim([0 0.5e-3]);
xlabel('Tiempo [s]');
ylabel('Voltaje de la carga [V]');
title('Voltaje de la carga en lazo abierto y en lazo cerrado')
grid on;

hold on
plot(out.vr_lazo_abierto2.Time,out.vr_lazo_abierto2.Data,'LineWidth',1.5)
grid on
legend('PID','Lazo abierto');


