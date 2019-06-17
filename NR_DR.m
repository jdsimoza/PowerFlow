#Valores iniciales
V = Bus(:,3);   #Matriz de Voltajes
P = Bus(:,5);   #Matriz de Potencias Activas
Q = Bus(:,6);   #Matriz de Potencias Reactivas

%___________Inicio del c�digo del programa NR Desacoplado R�pido__________
%Instrucciones
%para correr este programa se necesitan conectar 5 matrices.
%Estas matrices son
%A) la matriz (nxn) "Ybus" con los valores de la Ybus del sistema. 
%B) la matriz (1xn) "V" con los voltajes de cada barra
%C) la matriz (1xn) "P" con las potencias activas de cada barra (Pesp=Pgen-Pdem)
%D) la matriz (1xn) "Q" con las potencias reactivas de cada barra (Qesp=Qgen-Gdem)
%E) la matriz (1xn) "tipo" con la clasificaci�n de cada barra en su fila correspondiente de la siguiente manera: Slack=1 PQ=2 PV=3.
%F) IMPORTANTE Adem�s, es necesario que el orden de las barras sea registrado con las PQ una despu�s de la otra y las PV una despu�s de la otra en la organizaci�n del sistema

error_calculado = 1;        %Nombro la variable error_calculado 
iteracion = 0;              %Nombro la variable iteracion
[n,x] = size(Ybus);         %Genero la variable "n" con el tama�o del sistema
B = imag(Ybus);             %Genero la matriz B con las admitancias del sistema
tamB1 = 0;                  %Nombre la variable
tamB2 = 0;                  %Nombre la variable  
cont = 1;                   %Nombre la variable
d = zeros(1,n);
Pesp = P;
P = zeros(1,n);
Qesp = Q;
Q = zeros(1,n);
  
  
while (cont < n+1) 
    if (tipo(cont) == 2)    %Para barras PQ y PV
        tamB1 = tamB1 + 1;
        tamB2 = tamB2 + 1;
    endif
    if (tipo(cont)==3)    %Para barras PV
        tamB1 = tamB1 + 1; 
    endif
    cont = cont + 1;
endwhile
  

  B1 = zeros(tamB1);        %Para c�lculo de los �ngulos de los voltajes
  B2 = zeros(tamB2);        %Para c�lculo de los m�dulos de los voltajes
  dang = zeros(1,n);
  Pesp = zeros(tamB1,1);
  Qesp = zeros(tamB2,1);
  Vin = zeros(tamB2,1);
  
  %Procedo a generar las matrices de B'(B1) y B''(B2)
  
  fil_b1 = 1;       %Creo la variable
  fil_b2 = 1;       %Creo la variable
  col_b1 = 1;       %Creo la variable
  col_b2 = 1;       %Creo la variable
  reg_b = 1;        %Creo la variable
  L = 0;            %Creo la variable
  tam_b1 = 1;       %Creo la variable
  tam_b2 = 1;       %Creo la variable
  cont_p = 1;       %Creo la variable
  cont_q = 1;       %Creo la variable
  
while reg_b < n+1

  %Modifico la matriz que encontrar� los �ngulos de los voltajes
    if ((tipo(reg_b) == 2) || (tipo(reg_b) == 3)) %Para el caso donde se encuentran los �ngulos
        while tam_b1+L < tamB1+1        %Genero B1 a partir de los puntos de la matriz Ybus que sean PV y PQ
            B1(fil_b1, (col_b1+L)) = -B(reg_b, (reg_b+L));
            B1((fil_b1+L), col_b1) = -B((reg_b+L), reg_b);
            L = L + 1;
        endwhile
        L = 0;                              %Limpio la variable
        tam_b1 = tam_b1 + 1;                  %Llevo el contador avanzando dentro de la matriz B1 
        fil_b1 = fil_b1 + 1;                  %Contador punto de fila
        col_b1 = col_b1 + 1;                  %Contador punto de columna
        %(Aprovecho el while) y Tambi�n registro las Pesp en su matriz correspondientes
        Pesp(cont_p) = P(reg_b);
        Vin = V(cont_p);
        cont_p = cont_p + 1;
    endif
  
  %Modifico la matriz que encontrar� los m�dulos de los voltajes
    if (tipo(reg_b) == 3)
        while ((tam_b2 + L) < (tamB2 + 1))
            B2(fil_b2, (col_b2+L)) = -B(reg_b, (reg_b+L));
            B2((fil_b2+L), col_b2) = -B((reg_b+L), reg_b);
            L = L + 1;
        endwhile
        L = 0;
        tam_b2 = tam_b2 + 1;
        fil_b2 = fil_b2 + 1;
        col_b2 = col_b2 + 1;
        %(aprovecho el While) para registrar las Qesp en su matriz correspondientes para su futuro uso
        Qesp(cont_q) = Q(reg_b);
        cont_q = cont_q + 1;
    endif
  
    reg_b = reg_b + 1;
endwhile

%Reciclo las matrices P y Q para introducir en ellas las funciones P y Q para cada caso de PV y PQ seg�n sea el caso
P = zeros(tamB1,1);
Q = zeros(tamB2,1);
  
  %Inicio las iteraciones del m�todo 
while (error_calculado > Error)
    diang = dang;         %Matriz de �ngulos para futuras operaciones
    cont = 1;             %Inicio el contador para correr toda ina iteraci�n


%________________________-INICIO DE FUNCIONES DE P Y Q SEGUN SEA EL CASO DE LAS INCOGNITAS
    while  (cont < n+1)
        cont_p=1;
        cont_q=1;
        if (tipo(cont)==2||tipo(cont)==3) %Introduzco las f�rmulas para P en cada punto de la matriz P para futuros c�lculos (s�lo las que son incognitas)
            Ap=abs(V(cont)^2)*abs(Ybus(cont,cont))*cos(arg(Ybus(cont,cont)))
        
            while cont_p < n+1
                cont_p=cont_p+1;
            endwhile
        endif
        if (tipo(cont)==3)                  %Introduzco las f�rmulas para Q en cada punto de la matriz P para futuros c�lculos (s�lo las que son incognitas)
        endif
        cont=cont+1;
        a=1
    endwhile
   %______________________________FIN DE FUNCIONES P Y Q SEGUN SEA EL CASO DE LAS INCOGNITAS
   
   %Defino la matriz Da donde tendr� los diferenciales de las funciones de potencias P y Q
   Da1 = Pesp - P;
   Da2 = Qesp - Q; 
   %Defino los delta que posteriormente ser�n restados a los deltas anteriores para obtener el valor de las inc�gnitas
   Da1 = inv(B1)*Da1;
   Da2 = inv(B2)*Da2;
   
   Dd = Da1;           %registro el diferencial para calculo posterior
   DV = Da2;           %registro el diferencial para calculo posterior
   dang = diang + Dd;    %calculo finalmente los �ngulos incodnigta
   Vin = Vin + DV;       %calculo finalmente los m�dulos incodnigta
   
   %CALCULO EL ERROR DE LA ITERACI�N CORRESPONDIENDO AL VOLTAJE "m" (SEA CUAL SEA) Y LO COMPARO.
   Er1 = max(Dd);
   Er2 = max(DV);
   error_calculado = max([Er2, Er1]);        %Reciclo la matriz del "error_calculado" para iniciarla en 0
   
   %Registro una iteraci�n m�s del sistema
   iteracion = iteracion + 1;                  
 endwhile
 