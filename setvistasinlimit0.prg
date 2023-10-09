// Programa   : SETVISTASINLIMIT0
// Fecha/Hora : 18/12/2021 12:12:35
// Prop�sito  : Quitar LIMIT 0 en todas las vistas
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDb)
   LOCAL cSql:=[ SELECT * FROM DPVISTAS  WHERE VIS_DEFINE LIKE "%LIMIT 0%" ]
   LOCAL oTable,I
   LOCAL aVistasFix:="TABMONXCLI,NMHISMONMAXFCH,HISMONMAXVALOR,DPPROVEEDORBCO,DPCTABANCO"

   DEFAULT cDb:=oDp:cDsnData

   oTable:=OpenTable(cSql)

   WHILE !oTable:Eof()

     cSql:=STRTRAN(oTable:VIS_DEFINE," LIMIT 0","")
     EJECUTAR("DPVIEWADD",oTable:VIS_VISTA,oTable:VIS_NOMBRE,cSql)
     oTable:DbSkip()

  ENDDO

  oTable:End()

  aVistasFix:=aVistasFix+",ARCANUAL,CATEGORIA,CLIENTES,TABMONXCLI,DPCBTEDIA,DPCTABANCO,DOCCLICXCDIV,DOCPROCXPDIV,DOCPROCXP,ASIENTOS_DIAG,DOCPRODOC,DOCCLIDOC,DPDOCPRODOC,"+;
              "DPDOCPROCXPTIP,DPDOCPROPAG,PAISES_ESTADOS,NMHISMONMAXFCH,INVCATCONCAT,OBJFIN_COSTO,OBJFIN_GANANCIA,OBJFIN_GASTO,OBJFIN_VENTA,DOCCLIPAG,DOCPROPAG,DPINVPRECIOS,"+;
              "PRODUCTOS,DPPROVEEDORBCO,QUINCELIBCOM,QUINCELIBVTA,DPASIENTOSDIA,DPPROSLD,DOCCLIRMU,DPINVSLD,SUSTITUTOSCONCAT,TRANSFERENCIABCODEB,INVUBICAFISICA,"+;
              "VENTAS,EPED_PRODUCTOS"

  aVistasFix:=_VECTOR(aVistasFix,",")

  FOR I=1 TO LEN(aVistasFix)

     IF ISSQLFIND("DPVISTAS","VIS_VISTA"+GetWhere("=",aVistasFix[I]))
       EJECUTAR("SETVISTAS",NIL,aVistasFix[I],NIL,.T.,NIL,NIL)
     ENDIF

  NEXT I
   
RETURN .T.
// EOF