// Programa   : MYSQLSTRUCT
// Fecha/Hora : 17/04/2018 13:15:06
// Propósito  : Verificar de Manera Nativa si Existe MySql
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cField,oDb)
   LOCAL oTable,cSql,I,lResp:=.T.,lField:=.F.
   LOCAL aFields:={},nAt:=0,nT1:=SECONDS()
   LOCAL lTable:=.F.

   DEFAULT cTable:="DPTABLAS",;
           oDb   :=GetOdbc(cTable)

   DEFAULT oDp:lSqlSayErr:=.F.

   IF ValType(oDb)="C"
      oDb:=OpenOdbc(oDb)
   ENDIF

   IF Empty(cTable)
      RETURN {}
   ENDIF

 
   cTable:=UPPER(ALLTRIM(cTable))
   // 30/09/2023 Optimiza 

   nAt   :=ASCAN(oDp:aMyStruct,{|a,n| a[1]==cTable})

   IF nAt>0
      aFields:=ACLONE(oDp:aMyStruct[nAt,2])

      IF !Empty(cField)
         nAt:=ASCAN(aFields,{|a,n| a[1]==cField})

         IF nAt>0
            aFields:={aFields[nAt]}
         ENDIF

      ENDIF

      RETURN aFields
   ENDIF

   IF !EJECUTAR("DBISTABLE",oDb,cTable,.T.)
      RETURN {}
   ENDIF

   IF Empty(cField)
      cSql  :="SELECT * FROM "+cTable+" LIMIT 0"
   ELSE
      cSql  :="SELECT "+cField+" FROM "+cTable+" LIMIT 0"
   ENDIF

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

   IF ASCAN(aFields,{|a,n|Empty(a[1]) .OR. Empty(a[3])})>0
      MensajeErr("Versión de MySql Incompatible con "+oDp:cDpSys,"Contactenos www.adaptaproerp.com")
      SALIR()
      RETURN .F.
   ENDIF

   IF oTable:hMySt=0
      ? "Error Desde "+oTable:ClassName( ),::cSql
   ENDIF

   IF Empty(aFields)
      aFields:= MMxStruct( oTable:hMySt )
   ENDIF

   oTable:Close()

   // 30/09/2023
   IF Empty(cField)
     AADD(oDp:aMyStruct,{cTable,ACLONE(aFields)})
   ENDIF

   
RETURN aFields
// EOF

