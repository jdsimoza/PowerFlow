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
  end
end
#Cantidad de admitancias en derivacion de los Trx
for (i=1:NLines)
  if (Trx(i,5) != 1)
    NShunt = NShunt + 2;
  end
end
TotalNElements = NElements + NShunt;    #Cantidad de elementos del sistema: EOriginales + EEnDerivacion

#Construccion de la submatriz de impedancias en derivacion
GShunt = zeros(NShunt,1); #Conductancia en derivacion
BShunt = zeros(NShunt,1); #Susceptancia en derivacion
NodeShunt = zeros(NShunt,2); #Submatriz de barras de conexion de las admitancias en derivacion

#Construccion de la submatriz de barras de conexion de las admitancias en derivacion
k = 1;
#Barras de conexion de las admitancias en derivacion de las lineas
for(i=1:NLines)
  if (Lines(i,5) != 0)
    NodeShunt(k,2) = Lines(i,1);
    k = k + 1; 
    NodeShunt(k,2) = Lines(i,2);
    k = k + 1;
  end
end
#Barras de conexion de las admitancias en derivacion de los Trx
for(i=1:NTrx)
  if (Trx(i,5) != 1)
    NodeShunt(k,2) = Lines(i,1);
    k = k + 1; 
    NodeShunt(k,2) = Lines(i,2);
    k = k + 1;
  end
end

#Construccion de la GShunt y BShunt
k = 1;
for (i=1:NLines)
    if (Lines(i,5) != 0)
        BShunt(k,1) = sqrt(-1)*1/Lines(i,5);
        k = k + 1; 
        BShunt(k,1) = sqrt(-1)*1/Lines(i,5);
        k = k + 1;
    end
end
for (i=1:NTrx)
    if ((Trx(i,5) != 1))
        BShunt(k,1) = sqrt(-1)*((Trx(i,5)*Trx(i,5))-Trx(i,5))*(1/Trx(i,4));
        GShunt(k,1) = sqrt(-1)*((Trx(i,5)*Trx(i,5))-Trx(i,5))*(1/Trx(i,3));
        k = k + 1; 
        BShunt(k,1) = sqrt(-1)*(1-Trx(i,5))*(1/Trx(i,4));
        GShunt(k,1) = sqrt(-1)*(1-Trx(i,5))*(1/Trx(i,3));
        k = k + 1;
    end
end

#Matriz de admitancias en derivacion
YShunt = GShunt + BShunt
NodeShunt

#Se suman las admitancias en derivacion que estan conectadas a la misma barra
#(Resolucion de admitancias en paralelo)
for (i=1:rows(NodeShunt))
  Nodej = NodeShunt(i,2)
  k = i + 1;
  if (k < rows(NodeShunt)) 
    for(k=i+1:rows(NodeShunt))
      if (Nodej == NodeShunt(k,2))
        YShunt(i) = YShunt(i) + YShunt(k) #Suma del paralelo
        YShunt(k) = []                    #Se elinan los componentes una vez que se suman
        NodeShunt(k,:) = []
      end
    end
  end
end

