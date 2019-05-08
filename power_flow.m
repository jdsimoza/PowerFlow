#Nombre de archivo: power_flow.m
#Este es el programa principal desde el cual se ejecuta:
# 1.- La adquisicion de datos
# 2.- Y_bus.m
# 3.- GS.m
# 4.- NR.m
#Nota: Para el funcionamiento del programa se requiere el paquete para hojas de calculo
#      <https:octave.sourceforge.io/io/>
#      * Para cargarlo use el comando 'pkg load io'
#      * Para verificar la carga del paquete use el comando 'pkg list'

#Adquisicion de datos
[NumConfig,TxtConfig] = xlsread('data_io.xlsx', 'CONFIG');
Bus = xlsread('data_io.xlsx', 'BUS');
#[Busi, BusType, abs[V(pu)], arg[V], Pgen(pu), Qgen(pu), Pload(pu), Qload(pu)]
Lines = xlsread('data_io.xlsx', 'LINES');
#[Busi, Busj, R(pu), X(pu), Bshunt(pu)]
Trx = xlsread('data_io.xlsx', 'TRX');
#[Busi, Busj, Rcc(pu), Xcc(pu), TAP]

runtime = cputime;                                    #Contador del tiempo de ejecucion del calculo
#GS
#NR
printf('Tiempo total: %f segundos\n', cputime-runtime)#Salida del tiempo de ejecucion del calculo