clc
clear

%**************************************************************************
%{
   Progama de irradiancia Solar extraterrestre a lo largo de un día o a lo
   largo de un año para una lugar [Latitud] determinada.

        Evaluación del recurso solar
        Máster en energías
        Universidad Complutense de Madrid
        Elaborado por: Francisco José Pérez Zenteno

    Funcionamiento

    El programa devuelve los valores de irradiancia extraterrestre de un
    lugar en específico [latitud del lugar] a lo largo de un día en
    específico o a lo largo del año (que es un promedio de unos días    
    característicos de cada mes).

    Ejemplo de entrada: 

        Inserte la latitud deseada: [...]
        Desea conocer la irradiancia horaria o anual: 
         1 horaria
         2 anual 
        [...]
        
    
    
%}

%Inputs del programa
%dia_del_anyo   = '16 de octubre';
%latitud Madrid = 40.4165000
%longitud       = -3.7025600

latitud = input('Inserte la latitud deseada: ');
opcion = input('Desea conocer la irradiancia horaria o anual: \n 1 horaria\n 2 anual \n');
%irradiancia = 4921;            %Valor de constante solar en [kJ/m^2*h]
irradiancia = 1367;             %Valor de constante solar en [W/m^2]

% Opcion para conocer datos de irradiancia horaria.
if opcion == 1
    
    dia_del_anyo = input('Inserte el dia y mes que desea [Eje. 16 de Octubre]: \n', 's');
    
        %Métodos para filtrar el string de dia_del_anyo
        str = lower(dia_del_anyo);
        str = erase(dia_del_anyo,'de');
        str = split(str);                       %Separa la cadena en un vector

        dia = str2double(str(1,1));             %Obtiene el valor númerico de la cadena
        mes = string(str(2,1));                 %Obtiene el mes de la cadena

    opcion_2 = input('Inserte la opcion de hora deseada: \n 1 - LAT \n 2 - LST \n 3 - LMT \n 4 - Comparación entre horas \n');
    
    %LLamada de funciones para obtener la delta y Eo
    [delta, dia_completo, angulo_dia] = delta_spencer(dia,mes);
    eo = excentricidad(dia_completo);
    
    %Llamada de funciones para obtener la irradiancia del día señalado
    [hora, ir, angulo,tipo] = irradiancia_diaria(irradiancia,eo,delta,latitud,angulo_dia,opcion_2);
    ir_positiva = irradiancia_positiva(hora,ir);
    
    if not(isequal(tipo,'TODOS'))
        
        %Mostrar datos en la pantalla de comandos
        fprintf('\n************************ \n');
        fprintf('Los datos obtenidos son: \n');
        fprintf('Hora del día \t  irradiancia [kJ/m^2*h] \n');
        for i= 1:1:length(hora)
            if ir(i) > 0
                fprintf('  %g         \t        %g          \n',i,ir(i));
            end
        end
        
        %Gráfica de la irradiancia
        plot(hora,ir_positiva)
        titulo = sprintf('Irradiancia a lo largo del día: %s\n latitud: %g hora: %s',dia_del_anyo,latitud,tipo);
        title(titulo);
        xlabel('Hora del día');
        ylabel('Irradiancia [kJ/m^2*h]');
        
    end
   
%Opción para conocer la irradiancia anual
elseif opcion == 2
    
    irradiancia_anual(irradiancia, latitud);
    
    
    
end

%**************************************************************************

%**************************************************************************
% Funciones del programa

function [y, dia_completo, angulo_dia] =  delta_spencer( dia, mes)

mes = char(mes);
switch mes
    case 'enero'
        dia_completo = dia ;
    case 'febrero'
        dia_completo = dia + 31;
    case 'marzo'
        dia_completo = dia + 59;
    case 'abril'
        dia_completo = dia + 90;
    case 'mayo'
        dia_completo = dia + 120;
    case 'junio'
        dia_completo = dia + 151;
    case 'julio'
        dia_completo = dia + 181;
    case 'agosto'
        dia_completo = dia + 212;
    case 'septiembre'
        dia_completo = dia + 243;
    case 'octubre'
        dia_completo = dia + 273;
    case 'noviembre'
        dia_completo = dia + 304;
    case 'diciembre'
        dia_completo = dia + 334;
end

angulo_dia = ((2*pi)/365)*(dia_completo-1);   %valor del (gamma) para la formula de Spencer
angulo_dia = rad2deg(angulo_dia);
y = (180/pi)*(0.006918 - 0.399912*cosd(angulo_dia) + 0.070257*sind(angulo_dia) - 0.006758*cosd(2*angulo_dia) + 0.000907*sind(2*angulo_dia) - 0.002697*cosd(3*angulo_dia) + 0.00148*sind(3*angulo_dia));

%y = 23.45*sin((2*pi/365)*(dia_completo+284));
end

%Función para obtener la excentricidad de un día en específico
function e = excentricidad(dia)

e = 1 + 0.033*cos((2*pi*dia)/365);

end

%Función para calcular la irradiación a lo largo de 24 hrs
function [hora, irradiancia, angulo_horario, tipo] = irradiancia_diaria(isc, eo, delta, lat, angulo_dia, opcion)

hora = zeros(24,1);
irradiancia = zeros(24,1);
angulo_horario = zeros(24,1);

%Calculo de la irradiancia con la hora: LAT
if opcion == 1
    
    tipo = 'LAT';
    for i = 1:1:24
        angulo_horario(i) = 15*(12-i);             %Obtiene el angulo horario [w] del LAT
        ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario(i)));
        
        hora(i) = i;
        irradiancia(i) = ir;
    end
    
    %Calculo de la irradiancia con la hora: LST
elseif opcion == 2
    
    tipo = 'LST';
    long_merid = input('Inserte la longitud del meridiano de su zona horaria: ');
    long_ref = input('Inserte la longitud de referencia (justo donde se encuentra): ');
    %angulo_dia = input('Inserte el angulo del dia: ');
    
    for i = 1:1:24
        
        %El ciclo for sirve como la hora del reloj LST, de ahí se
        %pasa a la conversión de la hora de reloj a la hora real
        %del SOl con la función que convierte LST a LAT.
        LAT = LST2LAT(i, long_merid, long_ref, angulo_dia);
        
        angulo_horario(i) = 15*(12-LAT);             %Obtiene el angulo horario [w] del LAT
        ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario(i)));
        
        hora(i) = i;
        irradiancia(i) = ir;
        
        fprintf('Hora LST: %g  \t Hora LAT: %g\n',i, LAT);
    end
    
    %Calculo de la irradiancia con la hora: LMT
elseif opcion == 3
    
    tipo = 'LMT';
    for i = 1:1:24
        LAT = LMT2LAT(i,angulo_dia);
        angulo_horario(i) = 15*(12-LAT);             %Obtiene el angulo horario [w] del LAT
        ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario(i)));
        
        hora(i) = i;
        irradiancia(i) = ir;
        
        fprintf('Hora LMT: %g  \t Hora LAT: %g\n',i, LAT);
        
    end
    
    %Comparación de la irradiancia entre los distintos tipos de horas
elseif opcion == 4
    
    tipo = 'TODOS';
    long_merid = input('Inserte la longitud del meridiano de su zona horaria: ');
    long_ref = input('Inserte la longitud de referencia (justo donde se encuentra): ');
    
    %LAT
    for i = 1:1:24
        angulo_horario(i) = 15*(12-i);             %Obtiene el angulo horario [w] del LAT
        ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario(i)));
        
        hora_lat(i) = i;
        irradiancia_lat(i) = ir;
    end
    
    %LST
    for i = 1:1:24
        
        LAT = LST2LAT(i, long_merid, long_ref, angulo_dia);
        
        angulo_horario(i) = 15*(12-LAT);             %Obtiene el angulo horario [w] del LAT
        ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario(i)));
        
        hora_lst(i) = i;
        irradiancia_lst(i) = ir;
        
    end
    
    %LMT
    for i = 1:1:24
        LAT = LMT2LAT(i,angulo_dia);
        angulo_horario(i) = 15*(12-LAT);             %Obtiene el angulo horario [w] del LAT
        ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario(i)));
        
        hora_lmt(i) = i;
        irradiancia_lmt(i) = ir;
        
    end
    
    %Obtiene unicamente los valores de irradiación positiva
    irradiancia_lat = irradiancia_positiva(hora_lat,irradiancia_lat.');
    irradiancia_lmt = irradiancia_positiva(hora_lmt,irradiancia_lmt.');
    irradiancia_lst = irradiancia_positiva(hora_lst,irradiancia_lst.');
    
    %Datos
    for i = 1:1:24
        if irradiancia_lat(i) ~= 0
            fprintf('Hora: %g  \t Irradiancia [LAT]: %g \t Irradiancia [LMT]: %g \t Irradiancia [LST]: %g \n ',i, irradiancia_lat(i), irradiancia_lmt(i), irradiancia_lst(i));
        end
    end
    
    %Gráfica
    plot(hora_lat, irradiancia_lat, hora_lst, irradiancia_lst,'r', hora_lmt, irradiancia_lmt,'k');
    titulo = sprintf('Irradiancia a lo largo del día');
    title(titulo);
    xlabel('Hora del día');
    ylabel('Irradiancia [kJ/m^2*h]');
    legend('LAT','LST','LMT');
    
end
end

%Función que arroja solamente la irradiancía positiva
function g =  irradiancia_positiva(hora, irradiancia)

aux_ir = zeros(24,1);
for i = 1:1:length(hora)
    if irradiancia(i,1) >  0
        aux_ir(i,1) = irradiancia(i,1);
    else
        continue;
    end
end

g = aux_ir;

end

%Función para calculo de la irradiancia anual
function irradiancia_anual(isc, lat)

meses = (1:12);
dias_representativos = [17 45 74 105 135 161 199 230 261 292 322 347];
irradiancia = zeros(1,12);
angulo_horario = 0;             %Se considera el angulo horario al medio dia LAT = 12:00

for i = 1:1:12
    
    angulo_dia = rad2deg(((2*pi)/365)*(dias_representativos(i)-1));   %valor del (gamma) para la formula de Spencer
    delta = (180/pi)*(0.006918 - 0.399912*cosd(angulo_dia) + 0.070257*sind(angulo_dia) - 0.006758*cosd(2*angulo_dia) + 0.000907*sind(2*angulo_dia) - 0.002697*cosd(3*angulo_dia) + 0.00148*sind(3*angulo_dia));
    eo = excentricidad(dias_representativos(i));
    
    ir = isc*eo*(sind(delta)*sind(lat) + cosd(delta)*cosd(lat)*cosd(angulo_horario));
    irradiancia(i) = ir;
    
end

fprintf('\n************************ \n');
fprintf('Los datos obtenidos son: \n');
fprintf('Mes del año \t  irradiancia [W/m^2] \n');

for i= 1:1:length(meses)
   
    fprintf('  %g         \t        %g          \n',i,irradiancia(i));
   
end

plot(meses, irradiancia);
titulo = sprintf('Irradiancia a lo largo del año \n latitud: %g',lat);
title(titulo);
xlabel('Mes del año');
ylabel('Irradiancia [W/m^2]');

end

%{
Funciones para hacer la conversión entre los distintos tipos de horas

LAT - (Local Apparent Time) es el tiempo del Sol verdadero. Cuando el sol
       pasa sobre el meridiano local del observador.

LMT - (Local Mean Time) es el tiempo considerando un Sol ficticio que
        circula en una orbita circular. La duración del día es igual para cada día
        del año. Hace referencia también al meridiano del observador

LST - (Local Standard Time) es el tiempo de los relojes. Se toma de
        referencia el meridiano de Greenwich. Tomando como referencia 15º entre
        meridianos. En este se puede considerar factores políticos o geográficos

%}

function [hora, et] = LMT2LAT(lmt,angulo_dia)

et =229.18*(0.0000075 + 0.001868*cos(angulo_dia) - 0.032077*sin(angulo_dia) - 0.014615*cos(2*angulo_dia) - 0.040849*sin(2*angulo_dia));
hora = hours(lmt) + minutes(et);           %Suma los minutos obtenidos de et al tiempo LMT
hora = hours(hora);                        %Da el resultado en horas (considerando los minutos como decimales de la hora)

end

%Función que convierte la hora del reloj LST en la hora del Sol real
function [hora, et, dif_mer] = LST2LAT(lst, long_merid, long_ref, angulo_dia)

et = 229.18*(0.0000075 + 0.001868*cos(angulo_dia) - 0.032077*sin(angulo_dia) - 0.014615*cos(2*angulo_dia) - 0.040849*sin(2*angulo_dia));
dif_mer =  minutes(4*(long_merid - long_ref));
hora = hours(lst) + minutes(4*(long_merid - long_ref) + et);
hora = hours(hora);

end





