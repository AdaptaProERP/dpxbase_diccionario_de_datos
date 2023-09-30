// Programa   : ISFIELDMYSQL
// Fecha/Hora : 17/04/2018 13:15:06
// Propósito  : Verificar de Manera Nativa si Existe MySql
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDb,cTable,cField,lCreate)
   LOCAL oTable,cSql,I,lResp:=.T.,lField:=.F.
   LOCAL aFields:={},nAt:=0,nT1:=SECONDS()
   LOCAL lTable:=.F.

   DEFAULT cTable:="DPTABLAS",;
           oDb   :=GetOdbc(cTable),; 
           cField:="TAB_VISTA",;
           lCreate:=.F.

   IF !ValType(cField)="C" .OR. !ValType(cTable)="C"
      RETURN .F.
   ENDIF

   DEFAULT oDp:lSqlSayErr:=.F.

   IF ValType(oDb)="C"
      oDb:=OpenOdbc(oDb)
   ENDIF

   IF ValType(oDb)<>"O"
     MsgMemo("ISFIELDMYSQL oDb Debe ser Object, cTable "+CTOO(cTable,"C"))
     RETURN .F.
   ENDIF
  
   cTable:=UPPER(ALLTRIM(cTable))
   nAt   :=ASCAN(oDb:aTables,{|a,n| UPPER(a)==cTable})

   lTable:=(nAt>0)

   IF nAt=0
      //ASCAN(oDb:aTables,{|a,n| UPPER(a)==cTable})=0
      lTable:=DBISTABLE(oDb,cTable,lCreate)
   ENDIF

   IF !ValType(lTable)="L"
      MensajeErr("TIPO DE DATOS ISFIELDMYSQL lTable "+ValType(lTable))
      lTable:=.F.
   ENDIF

   IF !lTable .AND. !EJECUTAR("DBISTABLE",oDb,cTable,lCreate)
      RETURN .F.
   ENDIF

   aFields:=EJECUTAR("MYSQLSTRUCT",cTable) // 30/09/2023

   IF Empty(aFields)

     IF !oDp:oFileTracer=NIL
        oDp:oFileTracer:AppStr("ISFIELDMYSQL, cTable="+cTable+" cField:"+cField+CRLF)
     ENDIF

     oTable:=OpenTable("SELECT * FROM "+cTable,.F.,oDb)

     IF oTable:FIELDPOS(cField)=0
       oTable:End()
       RETURN .F.
     ENDIF

     oTable:End()

     cSql  :="SELECT * FROM "+cTable+" LIMIT 1"

     IF oDp:cTypeBD="MSSQL" 
       oTable:=OpenTable(cSql,.T.,oDb)
       aFields:=oTable:aFields
       oTable:End()

     ELSE

       oTable:=TMSTable():New( oDb, cTable ,,  )  // ,"1" Basado en Array
       oTable:oDataBase:=oDb
       oDb:Use()

       oTable:cStatement:=cSql

       IF !oTable:Open(cSql)

        IF ValType(oDb)="O"
           MySqlStart()
           oDb:oConnect:oError:Show( .T. )
        ENDIF

        IF  oDp:lSqlSayErr
          EJECUTAR("SQLMSGERR",cSql,cTable,oDb:cDsn,SECONDS()-nT1,GETPROCE(), oDp:cDpXbaseLine)
        ENDIF

        RETURN .F.

      ENDIF

      aFields:= ACLONE(oTable:aStruct)

      IF Empty(aFields) 
        aFields:= MMxStruct( oTable:hMySt )
      ENDIF

      oTable:Close()

    ENDIF

    IF Empty(aFields)
       oTable :=OpenTable(cSql,.F.,oDb)
       oTable:End()
       aFields:=oTable:aFields
    ENDIF

    IF !Empty(aFields) .AND. ASCAN(aFields,{|a,n|Empty(a[1]) .OR. Empty(a[3])})>0
       //ViewArray(aFields)
       MensajeErr("Versión de MySql Incompatible con "+oDp:cDpSys,"Contáctenos desde AdaptaPro www.adaptaproerp.com")
       SALIR()
       RETURN .F.
     ENDIF

  ENDIF

  IF ValType(cField)="A"

      FOR I=1 TO LEN(cField)

        nAt:=ASCAN(aFields,{|a,n| ALLTRIM(aFields[n,1])==ALLTRIM(cField[I])})

        IF nAt=0
           RETURN .F.
        ENDIF

      NEXT I
      
   ELSE

     nAt  :=ASCAN(aFields,{|a,n| ALLTRIM(aFields[n,1])==ALLTRIM(cField)})
     lResp:=(nAt>0)

   ENDIF

   IF !ValType(nAt)="N"
      RETURN .F.
   ENDIF

 
RETURN lResp
// EOF
