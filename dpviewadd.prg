// Programa   : DPVIEWADD
// Fecha/Hora : 13/03/2021 11:39:33
// Propósito  : Agregar Vistas
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cDescri,cSql,lRun,cCodPrg,cDsn)
   LOCAL oTable,cTable,cVistaName,cSql2,aTables,oDb,cVista
   LOCAL cFileErr:="TEMP\sqlmsgerror.TXT",cError

   DEFAULT cCodigo:="OBJFIN_COSTO",;
           cDescri:="Objetivo Financiero Gasto",;
           cSql   :=[SELECT OBD_FECHA  AS COS_FECHA,OBD_MONTO  AS COS_MONTO,OBD_MTOEJE AS COS_MTOEJE FROM dpobjfin_diario WHERE OBD_CODIGO="Costo" ],;
           lRun   :=.T.
          
   IF !" LIMIT "$cSql
      cSql2:=cSql+" LIMIT 0"
   ENDIF

   cSql:=STRTRAN(cSql,['],["])
   DpMsgSetText("Creando Vista "+cCodigo)

   oDp:lExcluye:=.F.

   oTable:=OpenTable(cSql2,.F.)
   cTable:=UPPER(oTable:cTable)

   oTable:End()

   IF cDsn=NIL

     IF UPPER(LEFT(cTable,5))="VIEW_"

        cVista:=UPPER(SUBS(cTable,6,LEN(cTable)))

        DEFAULT cDsn  :=SQLGET("DPVISTAS","VIS_DSN","VIS_VISTA"+GetWhere("=",cVista))

     ELSE

        DEFAULT cDsn  :=SQLGET("DPTABLAS","TAB_DSN","TAB_NOMBRE"+GetWhere("=",cTable))

     ENDIF

     oDb   :=OpenOdbc(cDsn)

  ENDIF

  DpMsgSetText("Creando Vista "+cCodigo+" "+cDsn)

  CursorWait()

  DEFAULT cCodPrg:=SQLGET("DPVISTAS","VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))

  EJECUTAR("CREATERECORD","DPVISTAS",{"VIS_VISTA","VIS_NOMBRE","VIS_TABLE","VIS_DSN","VIS_ACTIVO","VIS_INDICA","VIS_FECHA","VIS_PRGPRE"},; 
                                     {cCodigo    ,cDescri      ,cTable    ,cDsn     ,.T.         ,.F.         ,oDp:dFecha ,cCodPrg   },;
                                       NIL,.T.,"VIS_VISTA"+GetWhere("=",cCodigo))

  SQLUPDATE("DPVISTAS","VIS_DEFINE",cSql,"VIS_VISTA"+GetWhere("=",cCodigo))

  // JN 29/09/2023
  IF !Empty(cCodPrg)
     // 04/10/2023 EVITAR RECURSIVIDAD EJECUTAR(cCodPrg)
  ENDIF

  IF lRun

     
     // 08/09/2022, crea las tablas dependiente de las vistas 
     aTables:=EJECUTAR("SQL_ATABLES",cSql)
     AEVAL(aTables,{|a,n| EJECUTAR("DBISTABLE",oDb,a,.T.)})

     cVistaName:="VIEW_"+ALLTRIM(cCodigo)

     IF EJECUTAR("DBISTABLE",cDsn,cVistaName)

       DEFAULT oDb:=OpenOdbc(cDsn)

       oDb:ExecSQL("DROP TABLE IF EXISTS "+cVistaName,.F.)
 
       IF !oDb:ExecSQL("DROP VIEW "+cVistaName,.F.)
         oDb:ExecSQL("DROP TABLE "+cVistaName,.F.)
       ENDIF

     ENDIF

     EJECUTAR("DPVISTATOFIELD",cCodigo)
     EJECUTAR("DPVISTASTOTXT",cCodigo)

     FERASE(cFileErr)

     EJECUTAR("SETVISTAS",NIL,cCodigo,NIL,.T.,NIL,NIL)

     cError:=""

     IF !Empty(cDsn)
       oDb   :=OpenOdbc(cDsn)
       cError:=oDb:oConnect:oError:GetError()
     ENDIF

     IF !Empty(cError)
        MsgMemo(cError+CRLF+MemoRead(cFileErr)+CRLF+cFileErr,"No puedo crear la vista "+cCodigo)
     ENDIF


  ENDIF

RETURN .T.
// EOF
