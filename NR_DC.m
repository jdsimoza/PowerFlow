#Nombre de archivo: NR_DC.m
#Esta subrutina permite ejecutar obtener los resultados del flujo de potencia
#utilizando el metodo de Flujo de carga DC

#########################################################################################
#Lectura y preparacion de los datos
#########################################################################################
Ybus_DC(1, :) = []; #Se elimina la primera fila de la Ybus_DC
Ybus_DC(:, 1) = []; #Se elimina la primera columna de la Ybus_DC

Pg = Bus(:,5);  #Matriz de Potencias Activas Generadas
Pl = Bus(:,7);  #Matriz de Potencias Activas Demandadas
Pesp = Pg - Pl; #Matriz de Potencias especificadas

Pesp(1, :) = [];    #Se elimina la primera fila de la Pesp
#Nota: El motivo por el cual se eliminan las lineas y columnas de las matrices
#es que la barra 1 Slack no se considera dentro de los cálculos

#########################################################################################
#Estimacion de las fases del sistema
#########################################################################################
d_DC = inv(Ybus_DC)*Pesp