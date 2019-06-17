#Nombre de archivo: NR_vector.m
#Esta subrutina permite ejecutar armar las ecuaciones DeltaP y Delta Q
#Necesarias para el analisis del flujo de carga e incluirlas en orden
#Dentro del vector sol necesario para que Octave lo resuelva

function [sol] = NR_vector(param, nB, y, theta, nP, nQ)

#########################################################################################
#Lectura de datos
#########################################################################################
Bus = xlsread('data_io.xlsx', 'BUS');
#[Busi, BusType, abs[V(pu)], arg[V], Pgen(pu), Qgen(pu), Pload(pu), Qload(pu)]

V = Bus(:,3);   #Matriz de Voltajes
d = Bus(:,4);   #Matriz de fases
Pg = Bus(:,5);  #Matriz de Potencias Activas Generadas
Qg = Bus(:,6);  #Matriz de Potencias Reactivas Generadas
Pl = Bus(:,7);  #Matriz de Potencias Activas Demandadas
Ql = Bus(:,8);  #Matriz de Potencias Reactivas Demandadas

#Matrices de Potencias especificadas
Pesp = Pg - Pl;
Qesp = Qg - Ql;

#Definicion del tipo de barras
[~,BusType] = xlsread('data_io.xlsx', 'BUS', 'B2:B1048576'); #Posible arreglo al rango
#Para acceder BusType{BusNumber,1}
#BusType es una variable cell y se debe transformar en una matriz de char
BusType2 = zeros(rows(Bus),1);
for (n = 1:rows(Bus))
    x = cell2mat(BusType(n));
    switch (x)
        case 'SLACK'
            BusType2(n) = 1;
        case 'PQ'
            BusType2(n) = 2;
        otherwise
            BusType2(n) = 3;
        end
endfor
BusType = BusType2;
clear BusType2; #Limpieza de variable auxiliar
#########################################################################################

#########################################################################################
#Asignacion de variables
#########################################################################################
#De todos los parametros del sistema, algunos son constantes y otros variables
#Estos ultimos son actualizados en cada iteracion.
m = 1;
k = nP + 1;
for (n = 1: nB)
    x = BusType(n);
    switch (x)
        case (1)    #Barra Slack
            V(n) = V(n);    #Modulo y fase constantes
            d(n) = d(n);
        case (2)    #Barra PQ
            V(n) = V(n);    #Modulo constante y fase variable
            d(n) = param(m);
            m = m + 1; 
        otherwise   #Barra PV
            V(n) = param(k);  #Modulo y fase variables
            d(n) = param(m);
            m = m + 1;
            k = k + 1;
        end
endfor
#########################################################################################

#########################################################################################
#Construccion de las ecuaciones DeltaP y DeltaQ
#########################################################################################
#DeltaP = Pespi - Pi = 0 y DeltaQ = Qesp - Qi = 0
#Por lo tanto, estas son las ecuaciones que se deben cargar de parámetro de salida
#Para ser procesado por fsolve
k = 1;
P = 0;
Q = 0;

#Ecuaciones de P
for (k = 1: nP)
    for (n = 1:rows(Bus))
        if ((k + 1) == n)   #El contador inicia en k+1 porque no se toma en cuenta la Barra 1
            P = P + V(k+1)*V(n)*y(k+1,n)*cos(theta(k+1,n));
        endif
        P = P + V(k+1)*V(n)*y(k+1,n)*cos(d(k+1)-d(n)-theta(k+1,n));
    endfor
    sol(k) = Pesp(k+1) - P;
    P = 0;
endfor 

#Ecuaciones de Q
k = nP + 1; #Apuntador de la primera eq Q dentro de result
for (n = 1:rows(Bus))
    if (BusType(n) == 2)    #Revisa que barras son PQ
        for(m = 1: rows(Bus))
            if (n == m)
                Q = Q + (-1)*V(n)*V(m)*y(n,m)*sin(theta(n,m));
            endif
            Q = Q + V(n)*V(m)*y(n,m)*sin(d(n)-d(n)-theta(n,m));
        endfor
        sol(k) = Qesp(n) - Q
        Q = 0;
        k = k + 1; 
    endif
endfor
#########################################################################################