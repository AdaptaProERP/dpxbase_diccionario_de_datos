// Programa   : SETVISTAS
// Fecha/Hora : 19/08/2011 02:34
// Prop�sito  : Implementa Vistas en la Base de datos
// Aplicaci�n : 20 - Programaci�n
// Observaci�n:
/*
 * lForze -- Para forzar a que no pregunte si procesar las vistas
 * lBas   -- Para indicar si colocar barra de progreso (aun no disponible)
*/

#include "dpxbase.ch"

PROCE MAIN(cVisDSN,cVisCodigo,cVista,lForze,lBar , oDlg ,lSay ,cDsn )
   LOCAL oTable, cSql, cWhere:="",cTable
   LOCAL oServer := oDp:oMySQL
   LOCAL nMySql  :=VAL(oDp:cMySqlVersion)
   LOCAL lTodos  :=.F.
   LOCAL oMeter  :=oDp:oMeter

   DEFAULT cVisDSN:="",cVisCodigo:="",cVista:="",lForze:=.f.,lBar:=.t.

   DEFAULT lSay:=.T.

   // No crea las vistas

   DEFAULT oDp:lCreateView:=.T.,;
           oDp:lRunPrgView:=.T.

   IF !Empty(cVisCodigo)
       cVisCodigo:=ALLTRIM(UPPER(cVisCodigo))
   ENDIF

   IF !Empty(cVisCodigo) .AND. "VIEW_"$cVisCodigo
      cVisCodigo:=SUBS(cVisCodigo,6,LEN(cVisCodigo))
   ENDIF

   IF !Empty(cVisCodigo)

      cWhere := "WHERE VIS_VISTA"+GetWhere("=",cVisCodigo)+;
                IIF(!Empty(cVista)," AND VIS_NOMBRE"+GetWhere("=",cVista),"" )

      // Si no existe, lo importa desde TXT

      IF COUNT("DPVISTAS",cWhere)=0
         EJECUTAR("TXTTODPVISTAS",cVisCodigo)
      ENDIF

   ENDIF

   IF Empty(cWhere)

      cWhere:=" WHERE VIS_ACTIVO=1"

      IF cDsn=oDp:cDsnData
         cWhere:=cWhere+" AND LEFT(VIS_DSN,1)"+GetWhere("=","<")
      ELSE
         cWhere:=cWhere+" AND LEFT(VIS_DSN,1)"+GetWhere("=",".")
      ENDIF

? cWhere,"EN CREAR VISTAS"

      lTodos:=.T.

   ENDIF

   cSql := "SELECT * FROM DPVISTAS "+cWhere+" ORDER BY CONCAT(VIS_FECHA,VIS_HORA)"

   If !lForze

      oDp:lCreateView:=.T.

      If Empty(cVisCodigo) .AND. ;
         !MsgYesNo("Implementar todas las Vistas?", "Implementando Vistas")
         Return .f.
      EndIf

   EndIf

   IF !oDp:lCreateView 
       RETURN .F.
    ENDIF

   oTable:=OpenTable(cSql,.t.)

   IF oTable:RecCount()=0
      oTable:End()
      clpcopy(cSQL)
      MsgMemo("No hay registros para crear las Vistas..."+CRLF+cSql,"C�digo "+cVisCodigo)
      RETURN NIL
   ENDIF
   
   oTable:GoTop()

   IF lTodos .AND. oTable:RecCount()>0

     IF ValType(oMeter)="O"

        oMeter:SetTotal(oTable:RecCount())

        IF ValType(oDp:oSay)="O"
           oDp:oSay:SetText("Creando Todas las Vistas")
        ENDIF

     ELSE

        DpMsgRun("Espere","Creando Todas las Vistas",NIL,oTable:RecCount()) // ,lStop,lReset)
        DpMsgSetTotal(oTable:RecCount(),"Espere","Creando Todas las Vistas")

     ENDIF

   ENDIF

   
   While !oTable:Eof()

      SysRefresh(.T.)

      // cDsn  :=""
      cTable:=ALLTRIM(oTable:VIS_TABLE)

      IF !Empty(cTable) 
         // 14/09/2022 genera incidencia debido a que la vista no esta incluida en DPTABLAS
         // cDsn:=GetOdbc(cTable):cDsn
      ENDIF

      IF Empty(cDsn)
        cDsn  :=oTable:VIS_DSN
        cDsn  :=IIF("<"$cDsn,oDp:cDsnData  ,cDsn)
        cDsn  :=IIF("."$cDsn,oDp:cDsnConfig,cDsn)
        cDsn  :=IIF("-"$cDsn,oDp:cDsnDicc  ,cDsn)
      ENDIF

      IF lTodos

         IF ValType(oMeter)="O"
            oMeter:Set(oTable:RecNo())
            IF(ValType(oDp:oSay)="O",oDp:oSay:SetText("Vistas ["+ALLTRIM(oTable:VIS_VISTA)+" "+LSTR(oTable:RecNo())+"/"+LSTR(oTable:RecCount())+"]"),NIL)
         ELSE
            DpMsgSet(oTable:RecNo(),.T.,NIL,"Vista "+oTable:VIS_VISTA)
         ENDIF

      ENDIF

      // oDp:oFrameDp:SetText(cDsn+" donde ser� creada la Vista")

      IIF(ValType(oDlg)="O",oDlg:Say(1,0,oTable:VIS_VISTA),NIL)

      IF !Empty(cTable) .AND. !("VIEW_"$cTable) .AND. !EJECUTAR("DBISTABLE",cDsn,cTable,.T.)

        Checktable(cTable)

        IF !EJECUTAR("DBISTABLE",cDsn,cTable,.T.)
          MensajeErr("Tabla "+cTable+" no Existe, no es posible Crear la Vista "+oTable:VIS_VISTA)
        ENDIF

      ELSE
        
        // Revisa estructura antes de Ejecutar la Tabla
        IF !("VIEW_"$cTable) .AND. !Empty(cTable)
          // 04/10/2023 EJECUTAR("DBISTABLE",cDsn,cTable,.T.)
          CHECKTABLE(cTable)
        ENDIF

        //  ? cDsn,oTable:VIS_VISTA,oTable:VIS_DEFINE,oServer,oTable:VIS_NOMBRE,"aqui no se puede caer,cDsn,oTable:VIS_VISTA,oTable:VIS_DEFINE,oServer,oTable:VIS_NOMBRE"

        SETVISTAXBASE(cDsn,oTable:VIS_VISTA,oTable:VIS_DEFINE,oServer,oTable:VIS_NOMBRE)

      ENDIF

      oTable:Skip()

   EndDo

   oTable:End()

   IF lTodos 
      DpMsgClose()
   ENDIF

RETURN

FUNCTION SETVISTAXBASE(cDsn,cVista,cSql,oServer,cNombre)
   LOCAL oDb
   LOCAL cVistaName:="VIEW_"+ALLTRIM(cVista)
   LOCAL aTablas   :=EJECUTAR("SQL_ATABLES",cSql),I,cError
   LOCAL cSql2     :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE,VIS_DSN,VIS_TABLE","VIS_VISTA"+GetWhere("=",cVista))
   LOCAL cCodPrg   :=DPSQLROW(2,"")
   LOCAL cTable    :=ALLTRIM(DPSQLROW(4,""))
   LOCAL cCodigo   :=cVista
   LOCAL cFile    

   // no debe crear la vista, si ya existe, solo la elimina en el caso que el usuario lo solicite.
   IF !lForze .AND. oDb:FILE(cVistaName)
     // 04/10/2023 EJECUTAR("DBISTABLE",cDsn,cVistaName,.F.) .AND. !lForze
     RETURN .T.
   ENDIF

   IF Empty(cSql)
     cSql   :=cSql2
     aTablas:=EJECUTAR("SQL_ATABLES",cSql)
   ENDIF

   oDb:=OPENODBC(cDsn)

   FOR I=1 TO LEN(aTablas)

      aTablas[I]:=UPPER(aTablas[I])

      IF "VIEW_"$UPPER(aTablas[I])

        SETVISTAS2(aTablas[I],aTablas[I],oDb)

      ELSE

       IF !oDb:FILE(aTablas[I])
          EJECUTAR("DBISTABLE",cDsn,aTablas[I],.T.)
       ENDIF

      ENDIF

   NEXT I

 
RETURN CREARVISTA(cVista,cSql,cCodPrg)


/*
// Vista requiere Vista
*/
FUNCTION SETVISTAS2(cVistaName,cVista,oDb)
    LOCAL cCodigo   :=STRTRAN(UPPER(cVistaName),"VIEW_","")
    LOCAL cSql      :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))
    LOCAL cCodPrg   :=DPSQLROW(2,"")
    LOCAL aTablas   :=EJECUTAR("SQL_ATABLES",cSql),I,cError
    LOCAL cFile     :="TEMP\dpvista_"+ALLTRIM(cVista)+".sql"

    FOR I=1 TO LEN(aTablas)

      aTablas[I]:=UPPER(aTablas[I])

      IF "VIEW_"$aTablas[I]

        SETVISTAS3(SUBS(aTablas[I],6,LEN(aTablas[I])),aTablas[I],oDb)

      ELSE

        IF !oDb:FILE(aTablas[I])
          CheckTable(aTablas[I])
        ENDIF

      ENDIF

    NEXT I

    CREARVISTA(cVista,cSql,cCodPrg)

RETURN .F.

/*
// Vista requiere Vista
// PD, se podra crear la recursividad de una funci�n mediante la multi-instancia 
*/
FUNCTION SETVISTAS3(cCodigo,cVista,oDb)
    LOCAL cSql   :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))
    LOCAL cCodPrg:=DPSQLROW(2,"")
    LOCAL aTablas:=EJECUTAR("SQL_ATABLES",cSql),I,cError
    LOCAL cFile  :="TEMP\dpvista_"+ALLTRIM(cVista)+".sql"

    FOR I=1 TO LEN(aTablas)

      IF "VIEW_"$aTablas[I]

         SETVISTAS4(SUBS(aTablas[I],6,LEN(aTablas[I])),aTablas[I],oDb)

      ELSE

        IF !oDb:FILE(aTablas[I])
           EJECUTAR("DBISTABLE",cDsn,aTablas[I],.T.)
           // CheckTable(aTablas[I])
        ENDIF

       ENDIF

    NEXT I
   
RETURN CREARVISTA(cVista,cSql,cCodPrg)

/*
// Vista requiere Vista
// PD, se podra crear la recursividad de una funci�n mediante la multi-instancia 
*/
FUNCTION SETVISTAS4(cCodigo,cVista,oDb)
    LOCAL cSql   :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))
    LOCAL cCodPrg:=DPSQLROW(2,"")
    LOCAL aTablas:=EJECUTAR("SQL_ATABLES",cSql),I,cError
    LOCAL cFile  :="TEMP\dpvista_"+ALLTRIM(cVista)+".sql"

     IF "VIEW_"$aTablas[I]

        SETVISTAS5(SUBS(aTablas[I],6,LEN(aTablas[I])),aTablas[I],oDb)

      ELSE

        IF !oDb:FILE(aTablas[I])
          EJECUTAR("DBISTABLE",cDsn,aTablas[I],.T.)
          // CheckTable(aTablas[I])
        ENDIF

    ENDIF

    CREARVISTA(cVista,cSql,cCodPrg)

RETURN .F.


/*
// 6TO NIVEL DE RECURSIVIDAD
*/
FUNCTION SETVISTAS5(cCodigo,cVista,oDb)
    LOCAL cSql   :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))
    LOCAL cCodPrg:=DPSQLROW(2,"")
    LOCAL aTablas:=EJECUTAR("SQL_ATABLES",cSql),I,cError
    LOCAL cFile  :="TEMP\dpvista_"+ALLTRIM(cVista)+".sql"

     IF "VIEW_"$aTablas[I]

        SETVISTAS6(SUBS(aTablas[I],6,LEN(aTablas[I])),aTablas[I],oDb)

      ELSE

        IF !oDb:FILE(aTablas[I])
          EJECUTAR("DBISTABLE",cDsn,aTablas[I],.T.)
          CheckTable(aTablas[I])
        ENDIF

    ENDIF

    CREARVISTA(cVista,cSql,cCodPrg)

RETURN .F.

/*
// 6TO NIVEL DE RECURSIVIDAD
*/
FUNCTION SETVISTAS6(cCodigo,cVista,oDb)
    LOCAL cSql   :=SQLGET("DPVISTAS","VIS_DEFINE,VIS_PRGPRE","VIS_VISTA"+GetWhere("=",cCodigo))
    LOCAL cCodPrg:=DPSQLROW(2,"")
    LOCAL aTablas:=EJECUTAR("SQL_ATABLES",cSql),I,cError
    LOCAL cFile  :="TEMP\dpvista_"+ALLTRIM(cVista)+".sql"

     IF "VIEW_"$aTablas[I]

        ? "REQUIERE 7NIVEL PARA CREAR SETVISTAS7(SUBS(aTablas[I],6,LEN(aTablas[I])),aTablas[I],oDb)"

      ELSE

        IF !oDb:FILE(aTablas[I])
          EJECUTAR("DBISTABLE",cDsn,aTablas[I],.T.)
          CheckTable(aTablas[I])
        ENDIF

    ENDIF

    CREARVISTA(cVista,cSql,cCodPrg)

RETURN .F.


/*
// Realiza la Creaci�n de la Vista
*/
FUNCTION CREARVISTA(cVista,cSql,cCodPrg)
    LOCAL cFile  :="TEMP\dpvista_"+ALLTRIM(cVista)+".sql"
    LOCAL cCodigo:=SUBS(cVista,6,LEN(cVista)),cError 

    IF Empty(cSql)
       MensajeErr("Vista "+cVistaName+" no tiene Sentencia SQL")
       RETURN .F.
    ENDIF

    oDb:ExecSQL("DROP TABLE IF EXISTS "+cVista,.F.)

    cSql:=STRTRAN(cSql,[=\'],[='])
    cSql:=STRTRAN(cSql,[\'] ,['])

    cSql:=" CREATE OR REPLACE VIEW  "+cVista+" AS "+cSql
    cSql:=EJECUTAR("WHERE_VAR",cSql)

    DPWRITE("TEMP\dpvistas_"+cVista+".SQL",cSql)

    IF !Empty(cCodPrg) .AND. oDp:lRunPrgView
      EJECUTAR(cCodPrg)
    ENDIF

    IF !oDb:ExecSQL( cSql )

       cError:=oDb:oConnect:oError:GetError()

       DPWRITE(cFile,cSql+CRLF+cError)
       IF !Empty(cError)
          MensajeErr("MySQL no pudo ejecutar la sentencia "+CRLF+CLPCOPY(cSql+CRLF+cError)+CRLF+"LogFile "+cFile,cTitle)
       ENDIF


       EJECUTAR("SETVISTASFIX",cCodigo,cError)

       RETURN .F.

    ENDIF

    SysRefresh(.T.)

RETURN .T.

//EOF