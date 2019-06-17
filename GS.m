#Nombre de archivo: GS.m
#Esta subrutina permite ejecutar obtener los resultados del flujo de potencia
#utilizando el metodo iterativo de Gauss-Seidel

%_____________M�DULO GAUSS SEIDEL PARA N BARRAS___________--
%Instrucciones:
%para correr este programa se necesitan conectar 5 matrices.
%Estas matrices son
%A) la matriz (nxn) "Ybus" con los valores de la Ybus del sistema. 
%B) la matriz (1xn) "V" con los voltajes de cada barra
%C) la matriz (1xn) "P" con las potencias activas de cada barra (Pesp=Pgen-Pdem)
%D) la matriz (1xn) "Q" con las potencias reactivas de cada barra (Qesp=Qgen-Gdem)
%E) la matriz (1xn) "BusType" con la clasificaci�n de cada barra en su fila correspondiente de la siguiente manera: Slack=1 PQ=2 PV=3.

#Valores iniciales
V = Bus(:,3);   #Matriz de Voltajes
P = Bus(:,5);   #Matriz de Potencias Activas
Q = Bus(:,6);   #Matriz de Potencias Reactivas

%________C�DIGO DEL PROGRAMA
%GENERAMOS ALGUNOS VALORES QUE NECESITAREMOS AL INICIAR
Vref = V;                   %Matriz Vreferencia para corregir los voltajes PV
error_calculado = 1;        %Nombro la variable error_calculado 
iteracion = 0;              %Nombro la variable iteracion
[n,x]=size(Ybus);         %Genero la variable "n" con el tama�o del sistema

%INICIAMOS LA ITERACIONES
while error_calculado > Error
  Va=V;                   %Genero Va (para calcular posteriormente el error)
  m=1;                    %Genero variable "m" para que sirva de gu�a para el voltaje que se est� iterando
  
    while m < n+1         %OPERO DEPENDE DEL BusType DE LA BARRA
    
        if (BusType(m) == 1) %BARRA SLACK
            V(m)=V(m);
        endif
    
        if (BusType(m) == 2) %BARRA PQ
            Bpq=((P(m)-Q(m)*sqrt(-1))/conj(V(m)));
            npq=1;
            Apq=0;
            while npq < n+1
                if (npq != m)
                    Apq=Apq+(Ybus(m,npq)*V(npq));
                endif
                npq=npq+1;
            endwhile
            V(m)=(1/Ybus(m,m))*(Bpq-Apq);
        endif
    
        if (BusType(m) == 3)  %BARRA PV

            %OBTENGO Q
            Apv=0;
            npv1=1;
            while npv1 < n+1
                Apv=Apv+(Ybus(m,npv1)*V(npv1));
                npv1=npv1+1;
            endwhile
            Q(m)=-imag(conj(V(m))*Apv);
            
            %OBTENGO V
            Bpv=((P(m)-(Q(m)*sqrt(-1)))/conj(V(m)));
            Apv=0;
            npv2=1;
            while npv2 < n+1
                if (npv2 != m)
                    Apv=Apv+(Ybus(m,npv2)*V(npv2));
                endif
                npv2=npv2+1;
            endwhile
            V(m)=(Bpv-Apv)*(1/Ybus(m,m));
            
            %CORRIJO V
            V(m)=(V(m)/abs(V(m)))*Vref(m);
        endif
    
        %CALCULO EL ERROR DE LA ITERACI�N CORRESPONDIENDO AL VOLTAJE "m" (SEA CUAL SEA) Y LO COMPARO.
        cont=1;                   %Genero la variable cont para hacer ciclo en el error
        error_nuevo=abs(V-Va);    %Genero una matriz de errores calculados
        error_calculado=0;        %Reciclo la matriz del "error_calculado" para iniciarla en 0
        while cont < n+1
            if (error_nuevo(cont) > error_calculado)
                error_calculado=error_nuevo(cont);
            endif
        cont=cont+1;
        endwhile
        m=m+1;
    endwhile
    iteracion=iteracion+1;
endwhile

%MUESTRO EL VALOR DE TODOS LOS VOLTAJES (rectangular, m�dulo y �ngulo) Y ERRORES 
cont=1;
while cont < n+1
  
  b=V(cont);
  c=abs(V(cont));
  d=angle(V(cont));
  e=iteracion;
  
  printf("\nVoltaje %d(Rectangular): %d\n", cont, b);
  printf("\nVoltaje %d(Modulo): %d\n", cont, c);
  printf("\nVoltaje %d(Angulo): %d\n", cont, d);
  cont=cont+1;
end
printf("\nEstos resultados se han obtenido en %d iteraciones\n", iteracion);