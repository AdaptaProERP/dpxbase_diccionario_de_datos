// Programa   : DPEJERCICIOFIX
// Fecha/Hora : 05/05/2024 09:28:04
// Propósito  : Repara la fecha de Ejercicio
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cWhere:=""
  LOCAL oTable,dDesde,dHasta,nAno

  EJECUTAR("UNIQUETABLAS","DPEJERCICIOS","EJE_NUMERO")

  cWhere:=" (1=1) "

  oTable:=OpenTable("SELECT EJE_NUMERO,EJE_DESDE,EJE_HASTA FROM DPEJERCICIOS WHERE "+cWhere+" ORDER BY EJE_DESDE",.T.)

  WHILE !oTable:Eof()

     dDesde:=CTOD(LEFT(DTOC(oDp:EMP_FECHAI),6)+LSTR(YEAR(oTable:EJE_DESDE)))
     nAno  :=YEAR(dDesde)+IF(DAY(oDp:EMP_FECHAI)=1 .AND. MONTH(oDp:EMP_FECHAI)=1,0,1)
     dHasta:=CTOD(LEFT(DTOC(oDp:EMP_FECHAF),6)+LSTR(nAno))	

     IF !Empty(dDesde)
        SQLUPDATE("DPEJERCICIOS",{"EJE_DESDE","EJE_HASTA"},{dDesde,dHasta},"EJE_NUMERO"+GetWhere("=",oTable:EJE_NUMERO))
     ENDIF

     oTable:DbSkip()

  ENDDO

  oTable:End(.T.)

RETURN .T.
// EOF
