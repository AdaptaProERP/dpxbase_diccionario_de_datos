// Programa   : DSNTOVISTAS
// Fecha/Hora : 08/10/2023 19:35:58
// Propósito  : Asignar DSN desde la Tabla hacia la Vista
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cVista)
  LOCAL cWhere:="",cSql,oTable,aTables,cTable,cDsn,cDsnVista,aVistas:={}

  IF !Empty(cVista)
     cWhere:=" WHERE VIS_VISTA"+GetWhere("=",cVista)+" AND VIS_DSN<>TAB_DSN"
  ELSE
     cWhere:=" WHERE VIS_DSN<>TAB_DSN"
  ENDIF
  
  cSql  :="SELECT * FROM DPVISTAS LEFT JOIN DPTABLAS ON VIS_TABLE=TAB_NOMBRE AND VIS_DSN<>TAB_DSN "+cWhere
   oTable:=OpenTable(cSql,.T.)

  WHILE !oTable:Eof()

      cSql     :=oTable:VIS_DEFINE
      cDsnVista:=oTable:VIS_DSN
      cDsn     :=oTable:TAB_DSN
   
      WHILE .T.      

        SysRefresh(.t.)

        aTables:=EJECUTAR("SQL_ATABLES",cSql)
        cTable :=UPPER(aTables[1])
       
        IF "VIEW_"$cTable
           cVista   :=LEFT(cTable,6,LEN(cTable))
           cSql     :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_DSN","VIS_VISTA"+GetWhere("=",cVista))
           cDsnVista:=DPSQLROW(2)
           LOOP
        ENDIF

        EXIT

     ENDDO
  
     cDsn:=SQLGET("DPTABLAS","TAB_DSN","TAB_NOMBRE"+GetWhere("=",cTable))

     AADD(aVistas,{cTable,cDsn,cDsnVista})

     SQLUPDATE("DPVISTAS","VIS_DSN",cDsn,"VIS_VISTA"+GetWhere("=",cVista))
     // ViewArray(aTables)
     //? cSql,cTable,cVista,cDsn,oDp:cSql
     SysRefresh(.t.)
     oTable:DbSkip()
     //EXIT

  ENDDO

// ViewArray(aVistas)

  oTable:End()
            
RETURN .T.
// EOF

