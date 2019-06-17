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

#########################################################################################
#Adquisicion de datos
#########################################################################################
[~,TxtConfig] = xlsread('data_io.xlsx', 'CONFIG');
GsFlag = TxtConfig{2,2};                             #Char: "Y" o "N"
NrFlag = TxtConfig{3,2};                             #Char: "Y" o "N"
Error = xlsread('data_io.xlsx', 'CONFIG', 'B5');
MaxIteration = xlsread('data_io.xlsx', 'CONFIG', 'B6');
Bus = xlsread('data_io.xlsx', 'BUS');
#[Busi, BusType, abs[V(pu)], arg[V], Pgen(pu), Qgen(pu), Pload(pu), Qload(pu)]
[~,BusType] = xlsread('data_io.xlsx', 'BUS', 'B2:B1048576'); #Posible arreglo al rango
#Para acceder BusType{BusNumber,1}   
Lines = xlsread('data_io.xlsx', 'LINES');
#[Busi, Busj, R(pu), X(pu), Bshunt(pu)]
Trx = xlsread('data_io.xlsx', 'TRX');
#[Busi, Busj, Rcc(pu), Xcc(pu), TAP]
#########################################################################################

#########################################################################################
#Conversion cell2mat de BusType y asignacion de valores numericos a los tipos de barra 
#Slack=1, PQ=2 O PV=3
#########################################################################################
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
#########################################################################################

#########################################################################################
#Ejecucion del programa
#########################################################################################
#Construccion de la Y_bus
Y_bus;

#Ejecuta el metodo de GS y/o el de NR en funcion de los FLAGS
if (GsFlag = ('Y')) #Estos condicionales arrojan warnings, pero funcionan bien
    GS
    #RUNTIME
endif
if (GsFlag = ('Y'))
    #NR
    #RUNTIME
endif

#########################################################################################
#Limpieza de memoria
#########################################################################################
clear BusType2;
#clear BusType;
clear n;
clear x;