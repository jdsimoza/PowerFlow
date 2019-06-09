#Nombre de archivo: Y_bus.m
#Esta subrutina permite obtener la matriz Ybus del sistema
#El cálculo se realiza por medio del método de incidencia nodal

NNodes = rows(Bus);         #Cantidad de Barras/Nodos del sistema
NLines = rows(Lines);       #Cantidad de Lineas del sistema
NTrx = rows(Trx);           #Cantidad de Trx del sistema
NElements = NLines + NTrx;  #Cantidad de elementos del sistema

#Calculo de la cantidad de admitancias en derivacion
NShunt = 0;
#Cantidad de admitancias en derivacion de las lineas
for (i=1:NLines)
  if (Lines(i,5) != 0)
    NShunt = NShunt + 2;
  endif
endfor
#Cantidad de admitancias en derivacion de los Trx
for (i=1:NLines)
  if (length (Trx) >= 5)  #Solo realiza la operacion si existen Trx en el sistema
    if (Trx(i,5) != 1)
      NShunt = NShunt + 2;
    endif
  endif
endfor

#Construccion de la submatriz de impedancias en derivacion
GShunt = zeros(NShunt,1); #Conductancia en derivacion
BShunt = zeros(NShunt,1); #Susceptancia en derivacion
NodeShunt = zeros(NShunt,2); #Submatriz de barras de conexion de las admitancias en derivacion

#Construccion de la submatriz de barras de conexion de las admitancias en derivacion
k = 1;
#Barras de conexion de las admitancias en derivacion de las lineas
for (i=1:NLines)
  if (Lines(i,5) != 0)
    NodeShunt(k,2) = Lines(i,1);
    k = k + 1; 
    NodeShunt(k,2) = Lines(i,2);
    k = k + 1;
  endif
endfor
#Barras de conexion de las admitancias en derivacion de los Trx
for (i=1:NTrx)
  if (Trx(i,5) != 1)
    NodeShunt(k,2) = Lines(i,1);
    k = k + 1; 
    NodeShunt(k,2) = Lines(i,2);
    k = k + 1;
  endif
endfor

#Construccion de la GShunt y BShunt
k = 1;
for (i=1:NLines)
    if (Lines(i,5) != 0)
        BShunt(k,1) = sqrt(-1)*1/Lines(i,5);
        k = k + 1; 
        BShunt(k,1) = sqrt(-1)*1/Lines(i,5);
        k = k + 1;
    endif
endfor
for (i=1:NTrx)
    if ((Trx(i,5) != 1))
        BShunt(k,1) = sqrt(-1)*((Trx(i,5)*Trx(i,5))-Trx(i,5))*(1/Trx(i,4));
        GShunt(k,1) = sqrt(-1)*((Trx(i,5)*Trx(i,5))-Trx(i,5))*(1/Trx(i,3));
        k = k + 1; 
        BShunt(k,1) = sqrt(-1)*(1-Trx(i,5))*(1/Trx(i,4));
        GShunt(k,1) = sqrt(-1)*(1-Trx(i,5))*(1/Trx(i,3));
        k = k + 1;
    endif
endfor

#Matriz de admitancias en derivacion
YShunt = GShunt + BShunt;

#Se suman las admitancias en derivacion que estan conectadas a la misma barra
#(Resolucion de admitancias en paralelo)
i = 1;
while(i <= NShunt)
  Nodej = NodeShunt(i,2);
  k = i + 1;
  while (k <= NShunt)
    if (Nodej == NodeShunt(k,2))
      YShunt(i) = YShunt (i) + YShunt(k);
      YShunt(k) = [];
      NodeShunt(k,:) = [];
    endif
    k = k + 1;
    NShunt = rows(NodeShunt);
  endwhile
  i = i + 1;
  NShunt = rows(NodeShunt);
endwhile

#Matriz de admitancias primitivas del sistema
TotalNElements = NElements + NShunt;    #Cantidad de elementos del sistema: EOriginales + EEnDerivacion
Yp = zeros(TotalNElements, TotalNElements);
i = 1;
k = 1;
while (i <= NLines)
  Yp(k,k) = 1/(Lines(i,3)+(sqrt(-1)*Lines(i,4)));
  i = i + 1;
  k = k + 1; 
endwhile
i = 1;
while (i <= NTrx)
  Yp(k,k) = 1/(Trx(i,3) + (sqrt(-1)*Trx(i,4)));
  i = i + 1;
  k = k + 1; 
endwhile
i = 1;
while (i <= NShunt)
  Yp(k,k) = YShunt(i);
  i = i + 1;
  k = k + 1; 
endwhile

#Matriz de incidencia nodal
In = zeros(TotalNElements, rows(Bus))
i = 1;
k = 1;
while (i <= NLines)
  Busi = Lines(i,1);
  In(k,Busi) = 1;
  Busj = Lines(i,2);
  In(k,Busj) = -1;
  i = i + 1;
  k = k + 1;  
endwhile
i = 1;
while (i <= NTrx)
  Busi = Trx(i,1);
  In(k,Busi) = 1;
  Busj = Trx(i,2);
  In(k,Busj) = -1;
  i = i + 1;
  k = k + 1;
endwhile  
i = 1;
while (i <= NShunt)
  Busi = NodeShunt(i,2);
  In(k,Busi) = -1;
  i = i + 1;
  k = k + 1;
endwhile

InT = transpose(In); #Matriz de incidencia traspuesta
Ybus = InT*Yp*In     #Matriz Ybus