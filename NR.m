#Nombre de archivo: NR.m
#Esta subrutina permite ejecutar obtener los resultados del flujo de potencia
#utilizando el metodo iterativo de Newton-Raphson

#########################################################################################
#Valores iniciales
#########################################################################################
V = Bus(:,3);   #Matriz de Voltajes
d = Bus(:,4);   #Matriz de fases
Pg = Bus(:,5);  #Matriz de Potencias Activas Generadas
Qg = Bus(:,6);  #Matriz de Potencias Reactivas Generadas
Pl = Bus(:,7);  #Matriz de Potencias Activas Demandadas
Ql = Bus(:,8);  #Matriz de Potencias Reactivas Demandadas
Nb = rows(Bus);

#Matrices de Potencias especificadas
Pesp = Pg - Pl;
Qesp = Qg - Ql;

#Matriz de modulo y angulo de las impedancias
Y = abs(Ybus);
Theta = arg(Ybus);
#########################################################################################

#########################################################################################
#Calculo de cantidad de ecuaciones en funcion al tipo de barras
#########################################################################################
NP = rows(Bus) - 1; #Numero de ecuaciones P
NQ = 0;
for (n = 1: rows(BusType))
    if (BusType(n) == 2)    #Si la barra es de tipo PQ (tipo 2), incrementa NQ
        NQ = NQ + 1; 
    endif
endfor
NEqTotal = NP + NQ;         #Cantidad total de ecuaciones = NP + NQ 
#########################################################################################

#########################################################################################
#Vectores de las variables a determinar
#########################################################################################
Ang = zeros(NEqTotal, 1); 
Vbarra = ones(NQ, 1);
Xo = [Ang; Vbarra];     #Condiciones iniciales
#########################################################################################

#########################################################################################
#Fsolve
#########################################################################################
[result, fval, exitflag, iterations] = fsolve(@(X) NR_vector(X, Nb, Y, Theta, NP, NQ), Xo);
result
iterations