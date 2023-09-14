// Programa   : SQLMSGERR
// Fecha/Hora : 07/02/2011 04:52:00
// Propósito  : Monstrar Mensajes de Error SQL
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote)
   LOCAL oDlg,oFont,oFontB,oBtn,oMemo,oBtn,oFontB,oFontC,nAt,cField,cModo
   LOCAL cFile:="TEMP\SQLERR_"+LSTR(SECONDS())+".SQL"
   LOCAL lRet

   // Servidor Remoto no debe Evaluar Diccionario de datos
   // ? cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote,"cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote"

   DEFAULT cSql     :="",;
           cTable   :=cTable(cSql),;
           cProce   :=GETPROCE()  ,;
           cDpXbase :=oDp:oRunLine:oFunction:oScript:cProgram+" Function "+oDp:oRunLine:oFunction:cName+oDp:oRunLine:cLine,;
           lNoInsert:=.T.,;
           lRemote  :=.f.,;
           cError   :=oDp:oMySqlCon:oError:GetError()

   IF Empty(cError)
      cError   :=oDp:oMySqlCon:oError:GetError()
   ENDIF

   // utilizado por TDPEDIT/SAVE/ Muestra el mensaje de Error

   DPWRITE("TEMP\SQLMSGERROR.TXT",cError)

   oDp:cSqlErr:=cError

   IF !Empty(oDp:cFileToScr)
      EJECUTAR("TRAZATOREGSOPORTE")
   ENDIF

   DPWRITE(cFile,cSql+CRLF+cProce+CRLF+cError) 

   IF "timeout"$cError

      MensajeErr("1.Contacte a su Administrador de la base de Datos"+CRLF+"2. Definir los valores innodb_rollback_on_timeout=<nValor> según volumen de datos "+cError+CRLF+cSQL,"Sentencia por definición de MySQL ")

      EJECUTAR("DPINTSAVEFAILED",cTable,"",cDb,cSql+" "+CRLF+cDpXbase,"ERRNO",cError)
      EJECUTAR("DPREGSOPORTEAUTO","SQL",cTable,cSql,cError)

      RETURN NIL

   ENDIF

   IF !Empty(cError) .AND. "Cannot add foreign key constraint"$cError

      MensajeErr(cError+CRLF+"Tabla no puede ser Creada"+CRLF+"Será removida la Integridad Referencial")
      EJECUTAR("DPDROPALL_FK",oDp:cDsnData)
      EJECUTAR("DPDROPALL_FK",oDP:cDsnConfig)
 
   ENDIF

   IF "child"$cError

      OpenOdbc(oDp:cDsnData):Execute(" SET FOREIGN_KEY_CHECKS = 0")
      OpenOdbc(oDp:cDsnConfig):Execute(" SET FOREIGN_KEY_CHECKS = 0")

      // Debe realizar la Operación
           
      CLPCOPY(cSql)

      MensajeErr("1.Será Desactivada Provisionalmente la Integridad Referencial"+CRLF+"2.Utilice la Opción Actualizar Estructura de Datos"+CRLF+cError+CRLF+cSQL,"Sentencia de Integridad Refencial ")

//    EJECUTAR("DPDROPALL_FK",cDb)

      EJECUTAR("DPINTSAVEFAILED" ,cTable,"",cDb,cSql+" "+CRLF+cDpXbase,"ERRNO",cError)
      EJECUTAR("DPREGSOPORTEAUTO","SQL",cTable,"Integridad Referencial "+cTable,cSql+CRLF+cError+CRLF+GetProce())

      // IF !TYPE("oChkD")="O"
         // EJECUTAR("DPCHKSTRUCT")
      // ENDIF

      RETURN NIL

   ENDIF


// ? cError
//
// ? oDp:cSqlErr,"oDp:cSqlErr"
// ? cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote,"cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote"
// ? oDp:oMySqlCon:oError:GetErrNo(),"ERROR MYSQL",cError,cSql
// ErrorSys(.T.)

   IF !Empty(oDp:cFileSqlMsgErr)

      IF !Empty(cError) .AND. "@"$cError .AND. !"TRIGGE"$cError
        lRet:=EJECUTAR("MYSQLCREATEUSER",cError,cSql)
      ENDIF

// ? cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote,"cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote"

      oDp:oFileSqlMsgErr:=TFile():New(oDp:cFileSqlMsgErr)
      oDp:oFileSqlMsgErr:AppStr( cSql+CRLF+cProce+CRLF+cError+CRLF+REPLI("-",120)+CRLF )
      oDp:oFileSqlMsgErr:Close()

      RETURN .T.

   ENDIF

   DPWRITE(cFile,cSql+CRLF+cProce+CRLF+cError) 

 //  EJECUTAR("DPREGSOPORTEAUTO","SQL","","Incidencia SQL",cSql+CRLF+cProce+CRLF+cError,.F.)

  // "TEMP\SQLERR.SQL",cSql)

   EJECUTAR("FILETOSCRSAY",GETPROCE()+CRLF+cSql+CRLF+cError)

   IF !Empty(cError) .AND. ("150)"$cError)
      RETURN .T.
   ENDIF

   IF !Empty(cError) .AND. ("bigger"$cError .OR. "ALTER"$(cSql))

      cError:=cError+IF(!Empty(cTable),CRLF+"Tabla  "+cTable,"")
      cError:=cError+IF(!Empty(cSql)  ,CRLF+"Sentencia "+cSql,"")

      MensajeErr("Sentencia SQL Rechazada por el Servidor de Base Datos "+CRLF+cError+CRLF+cDpXbase,"Mensaje SQL")

      DPWRITE("TEMP\"+cTable+LSTR(SECONDS())+"_error.SQL",cSql)

      IF !Empty(cSql)
         DPWRITE("SQLERR.SQL",cSql)
      ENDIF

      RETURN .F.
   ENDIF

   // Descargar Diccionario desde AdaptaPro Server, Solo debe estar Activo en Revision del Diccionario de Datos
   // No se puede Utilizar para Reinstalar o Instalar el Sistema

   DEFAULT oDp:lDiccServer:=.F.

// IF Empty(cSql)
//   cSql:=MemoRead("error.sql")
// ENDIF
// ? CLPCOPY(cError),"Error"

   IF Empty(cSql) .AND. Empty(cError)
      RETURN NIL
   ENDIF

   IF !Empty(cError) .AND. "references invalid table(s)"$cError
      RETURN EJECUTAR("VIEW_ERRORINVOKE",cError)
   ENDIF

   IF !Empty(cError) .AND. "Unknown column"$cError .AND. "INSERT INTO"$cSql
      EJECUTAR("DPERRSQLINSERT",cSql,cDb,cDpXbase,cError,oDb,cTable)
      RETURN NIL
   ENDIF 

   IF !Empty(cError) .AND. "Table"$cError .AND. "doesn"$cError
     RETURN EJECUTAR("SQL_UNKNOWNCOL",cSql)
   ENDIF

   IF !Empty(cError) .AND. "Unknown column"$cError .AND. "SELECT"$cSql
      EJECUTAR("FIELDUNKNOWN",cSql,cError,.T.)       
      RETURN NIL
   ENDIF 



   // Campo Exede su Capacidad
   IF !Empty(cError) .AND. "Data too long"$cError .AND. "INSERT INTO"$cSql

       MsgRun("Actualizando Ancho de Campo")

       lRet:=EJECUTAR("SQLERR_TOOLONG",cError,cSql,oDb)

       IF lRet
         RETURN NIL
       ENDIF

   ENDIF 

   // Campo Exede su Capacidad con UPDATE  
   IF !Empty(cError) .AND. "Data too long"$cError .AND. "UPDATE"$cSql

       MsgRun("Actualizando Ancho de Campo")

       lRet:=EJECUTAR("SQLERR_TOOLONGUPDATE",cError,cSql,oDb)

       IF lRet
         RETURN NIL
       ENDIF

   ENDIF 

   IF !Empty(cError) .AND. "@"$cError

      IF "denie"$cError
         MsgMemo(cError+CRLF+cSql)
         RETURN NIL
      ENDIF

      MsgMemo("Para resolver esta incidencia "+CRLF+cError+CRLF+;
              "AdaptaPro removerá y creará todas las vistas para remover el ID del usuario ")

      lRet:=EJECUTAR("MYSQLCREATEUSER",cError,cSql)

      IF lRet
        RETURN NIL
      ENDIF

   ENDIF

   // Vista recuperada como tabla no podrá ser creada
   IF !Empty(cError) .AND. "is not VIEW"$cError .AND. "CREATE"$cSql

       MsgRun("Resolviendo Vista Recuperada como Tabla")

       lRet:=EJECUTAR("SQLERR_ISNOTVIEW",cError,cSql,oDb)

       IF lRet
         RETURN NIL
       ENDIF

   ENDIF 


   /*
   // Tablas que no pueden ser creadas por tener vinculos en el diccionario de datos
   */
   IF !Empty(cError) .AND. "Cannot add fore"$cError .AND. "CREATE TABLE"$cSql

       MsgMemo("AdaptaPro Creará una Nueva Base de datos con una Nueva Empresa"+CRLF+"El Sistema será Cerrado e Ingrese Nuevamente"+CRLF+cError+CRLF+cSql,;
               "No es Posible crear copia de los registros",600,700)

       EJECUTAR("DPEMPRESADUPLICA",oDp:cDsnData,NIL,.F.,.F.,.T.)
       WINEXEC(GetModuleFileName( GetInstance() ),.T.)
       EJECUTAR("DPFIN",.T.)
       SALIR()
 
       RETURN NIL

   ENDIF 

   //
   // JN 18/03/2019, respaldos recuperados, asumen vistas como tablas, genera incidencias para removerlas

   //
   IF !Empty(cError) .AND. "NOT VIEW"$UPPER(cError)
      cSql:=STRTRAN(cSql,"DROP VIEW","DROP TABLE")
      oDb:Execute(cSql)
      RETURN NIL
   ENDIF 

   
   // No debe mostrar este mensaje 
   IF !Empty(cError) .AND. ("150"$UPPER(cError) .AND. "ERRNO"$UPPER(cError))
      EJECUTAR("DPINTSAVEFAILED",cTable,"",cDb,cSql+" "+CRLF+cDpXbase,"ERRNO",cError)
      RETURN NIL
   ENDIF 

// ? cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote,"cSql,cTable,cDb,nTime,cProce,cDpXbase,lNoInsert,oDb,cError,lRemote"

   IF ValType(oDb)="O"

      DEFAULT cError:=oDb:oConnect:oError:GetError()

   ENDIF

   // Vistas Importadas desde Respaldos
   IF !Empty(cError) .AND. "The user"$cError .AND. "VIEW"$cSql
      MensajeErr("Incidencia Causada por Vistas generadas desde respaldo","Serán removidas todas las vistas")
      EJECUTAR("DROPALLVIEW",cDb)
   ENDIF 
 
   //
   // 21/04/2019
   // No muestra Ningun Mensaje de Incidencia, solo los guarda para ser visualizados
   //
   IF oDp:lMySqlError .AND. !Empty(cError) .AND. !Empty(cTable)
      EJECUTAR("DPINTSAVEFAILED",cTable,"",cDb,cSql+" "+CRLF+cDpXbase,"ERRNO",cError)
      RETURN NIL
   ENDIF


   IF !Empty(oDp:cDsnLock)
      SQLEJECUTAR("UNLOCK TABLES",oDp:cDsnLock)
   ENDIF

   IF lRemote
     MensajeErr("Sentencia SQL Rechazada por el Servidor de Base Datos "+CRLF+cError+CRLF+cSQL,"Mensaje SQL")
     RETURN NIL
   ENDIF

   IF Empty(cDb) .AND. !Empty(DpGetTables(.F.)) .AND. !Empty(cTable)
      cDb   :=IF(SQLGET("DPTABLAS","TAB_CONFIG","TAB_NOMBRE"+GetWhere("=",cTable)),oDp:cDsnConfig,oDp:cDsnData)
   ENDIF

   IF Empty(cDb)
      cDb   :=""
   ENDIF

   IF "INSERT INTO"$cSql .AND. Empty(cTable)
      cTable:=SUBS(cSql,AT("INTO ",cSql),LEN(cSql))
      cTable:=STRTRAN(cTable,"INTO ")
      cTable:=LEFT(cTable,AT(" ",cTable))
   ENDIF

   // JN 08/02/2016
   IF !Empty(cTable)

      DEFAULT oDb   :=GetOdbc(cTable),;
              cError:=oDb:oConnect:oError:GetError()

   ENDIF

   DPWRITE("SQLERR.SQL",cSql)

   IF !Empty(cError)
     DPWRITE("SQLERR.ERR",cError)
   ENDIF

   IF !Empty(cDb) .AND. oDb=NIL
      oDb   :=OpenOdbc(cDb)
   ENDIF

   IF Empty(cError) .AND. !oDb=NIL
      cError:=oDb:oConnect:oError:GetError()
   ENDIF

   IF !Empty(cDb)
      SQLEJECUTAR("UNLOCK TABLES",cDb)
   ENDIF

   IF "doesn't exist"$cError
      // Table 'dpsgev51.view_docclirep' doesn't exist
      cTable:=STRTRAN(cError,"doesn't exist","")
      cTable:=STRTRAN(cTable,"Table","")
      nAt   :=AT(".",cTable)
      cTable:=IF(nAt=0,cTable,SUBS(cTable,nAt+1,LEN(cTable)))
      cTable:=UPPER(STRTRAN(cTable,"'",""))
      //  JN 28/08/2018, Si la vista no existe, debe buscarla cTable:=STRTRAN(cTable,"VIEW_","")
   ENDIF

/*
// Genera Incidencia con error en INSERTINTO, se paso mas abajo,
? cTable,"cTable"

   IF Valtype(oDb)="O".AND. !Empty(cTable) .AND. ValType(cTable)="C" .AND. "doesn't exist"$cError


      IF !oDb:FILE(cTable) 

       IF "VIEW_"=UPPER(LEFT(cTable,5))
          EJECUTAR("SETVISTAS",cDb,cTable)
        ELSE
          CheckTable(cTable)
       ENDIF

     ENDIF

   ENDIF
*/

   IF !Empty(cError) .AND. "Unknown column"$cError 
      EJECUTAR("SQL_UNKNOWNCOL",cSql) // Revisa la estructura de los datos
   ENDIF

   IF !Empty(cError) .AND. "Unknown column"$cError .AND. oDp:lDiccServer

    
      EJECUTAR("SQL_UNKNOWNCOL",cSql) // Revisa la estructura de los datos

      nAt   :=AT(CHR(39),cError)
      cField:=IF(nAt>0,SUBS(cError,nAt+1,LEN(cError)),cError)
      nAt   :=AT(CHR(39),cField)
      cField:=IF(nAt>0,LEFT(cField,nAt-1),cField)

      IF "VIEW_"=UPPER(LEFT(cTable,5))

        EJECUTAR("SETVISTAS",cDb,cTable)

      ELSE

        IF ValType(cTable)="C"
          CheckTable(cTable)
        ENDIF

        IF !Empty(cField)
          MsgRun("Actualizando Diccionario de Datos","Por favor espere..",{||EJECUTAR("ISFIELDBDF",cTable)})
        ELSE
          MsgRun("Actualizando Diccionario de Datos","Por favor espere..",{||EJECUTAR("DPTABLANODICCDAT",cTable)})
        ENDIF

      ENDIF

      cError:=cError+CRLF+"Se ejecutó exploración del Diccionario de datos para Ingresar Campo Faltante"

   ENDIF

   // JN 13/03/2015 Si tiene campos memos, no lo envia

   IF "INSERT INTO"$cSql .AND. COUNT("DPCAMPOS","CAM_TABLE"+GetWhere("=",cTable)+" AND CAM_TYPE"+GetWhere("=","M"))=0

      EJECUTAR("DPINTSAVEFAILED",cTable,"",cDb,cSql+" "+CRLF+cDpXbase,"INSERT",cError)

      EJECUTAR("DPERRSQLINSERT",cSql,cDb,cDpXbase,cError,oDb)

	 RETURN .F.
   ENDIF



   /*
   // 21/11/2016
   */
   IF "ALTER TABLE"$cSql

      // Ejecuta la reparación de la Tabla
      EJECUTAR("ALTERTABLEFIX",cSql,cError,cDb)

      nAt   :=AT("TABLE",cSql)
      cTable:=ALLTRIM(SUBS(cSql,nAt+6,LEN(cSql)))
      cTable:=LEFT(cTable,AT(" ",cTable))

      EJECUTAR("DPINTSAVEFAILED",cTable,"",cDb,cSql,"ALTER",cError)

      IF !oDp:lSayCheckTab // JN 21/11/2016
         RETURN .F.
      ENDIF

   ENDIF

   IF Valtype(oDb)="O".AND. !Empty(cTable) .AND. ValType(cTable)="C" .AND. !oDb:FILE(cTable) 

      IF "VIEW_"=UPPER(LEFT(cTable,5))

        EJECUTAR("SETVISTAS",cDb,cTable)

        IF !oDb:FILE(cTable) 
           MsgRun("Actualizando Diccionario de Datos","Por favor espere..",{||EJECUTAR("DPTABLANODICCDAT",cTable)})
        ENDIF

      ELSE
        CheckTable(cTable)
      ENDIF

   ENDIF


   cSql:="DB:"+cDb+CRLF+ALLTRIM(cSql)+CRLF+;
         IF(Empty(cError),"",REPLI("-",80)+CRLF+"Mensaje MYSQL: "+cError+CRLF)+;
         "DpXbase:"+REPLI("-",80)+CRLF+cDpXbase+IIF(oDp:lTracer,CRLF+CTOO(oDp:cDpXbaseTraza,"C"),"")+CTOO(DPXGETPROCE(),"C")

   IF !Empty(DpGetTables(.F.))
      EJECUTAR("DPTRAZASQL",cSql,cTable,cDb,nTime,.T.)
   ENDIF

   IF Empty(oDp:cMsgFile)
      CLPCOPY(cSql)
   ENDIF

   IF .T.

     nAt  :=AT(cSql," ")
     cModo:=IF(nAt>0,LEFT(cSql,nAt),"INDEF")

     MensajeErr("Sentencia SQL Rechazada por el Servidor de Base Datos "+CRLF+cSQL,"Mensaje SQL")

     EJECUTAR("DPINTSAVEFAILED",cTable,"",cDb,cSql,cModo,cError)

 //  EJECUTAR("DPREGSOPORTEAUTO","TAB",cTable,"BD:"+cDb+"/"+cError,cSql+CRLF+"DpXbase["+cDpXbase+"]")  

   ELSE
     MsgMemo("Sentencia SQL Rechazada por el Servidor de Base Datos "+CRLF+cSQL+CRLF+cError,"Mensaje SQL",800,500)
   ENDIF

   EJECUTAR("FIXFOREIGNKEY",cSql)

RETURN .F.
// EOF


