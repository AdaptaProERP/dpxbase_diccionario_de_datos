// Programa   : SETVISTASFIX
// Fecha/Hora : 20/04/2020 09:04:52
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cError)
  LOCAL lResp:=.T.,I
  LOCAL nAt
  LOCAL cSql   
  LOCAL cCodPrg
  LOCAL aTablas
  LOCAL cFile  
  LOCAL cVista 

  DEFAULT cCodigo:="HISMONMAXVALOR"
               
  cSql   :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))
  cCodPrg:=DPSQLROW(2,"")
  aTablas:=EJECUTAR("SQL_ATABLES",cSql)
  cFile  :="TEMP\dpvista_"+cCodigo+".sql"
  cVista :=cCodigo

  DEFAULT cError:=" la columna "+GetWhere("","MAX_HORA")+" en field list"

  nAt:=AT(['],cError)

// ViewArray(aTablas)
// IF nAt>0
// ENDIF

  FOR I=1 TO LEN(aTablas)

    IF "VIEW_"$aTablas[I]
       cVista:=SUBS(aTablas[I],6,LEN(aTablas[I]))
       EJECUTAR("TXTTODPVISTAS",cVista,.F.)
    ELSE
       Checktable(aTablas[I])
    ENDIF

  NEXT I

// ? CLPCOPY(cError),"cError",nAt,cVista,"<-cVista"

RETURN lResp
// EOF

