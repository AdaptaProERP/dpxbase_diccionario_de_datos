// Programa   : DPCREABDFROMSCRIPT
// Fecha/Hora : 07/07/2023 23:43:00
// Propósito  : Crear Base de Datos desde DPSGEV60\DPSGEV60.SQL 
//              refrescará mysqldump.exe solo estructura de datos + Vistas anexadas desde aqui.
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDbOrg,cDbDes)
    LOCAL x       :=EJECUTAR("DPLOADCNFCHKFCH")
    LOCAL cId     :=oDp:cBdRelease
    LOCAL cComand:="",cBat:="RUN.BAT",cOut,oData,aDir,cNo:=""
    LOCAL cFileZip,aFiles,cLog,cSay,cCodEmp
    LOCAL cDir    :="DP"+oDp:cType+"V"+STRZERO(oDp:nVersion*10,2)
    LOCAL cFileOrg:=lower(oDp:cBin+cDir+"\"+cDir+".SQL")
    LOCAL cFileDes,cFileView,cFile
    LOCAL cMemo:="",nAt
    LOCAL cFileLog:=oDp:cBin+"TEMP\MYSQL_"+LSTR(SECONDS())+".LOG"
    LOCAL cFileMem:="MYSQL.MEM"
    LOCAL _MycPass:="",_MycLoging:="",cPass,cLogin,nT1,nAT,oDb,cBdChk
    LOCAL aVistas :=ACLONE(oDp:aVistas),cVistas:="",cRelease:="",cFileTmp:="",cFileView,cSql,aTables,lViewJoin:=.F.
    
    ADEPURA(aVistas,{|a,n| LEFT(a[3],1)="."})

    REST FROM (cFileMem) ADDI

    cPass  :=ENCRIPT(_MycPass  ,.F.)
    cLogin :=ENCRIPT(_MycLoging,.F.)

    DEFAULT cDbDes:="SGEV60_TEST_"+LSTR(LEN(oDp:oMySqlCon:aDatabases)),;
            cDbOrg:="DP"+oDp:cType+"V"+STRZERO(oDp:nVersion*10,2)


    cFileTmp:=cFileNoExt(cFileOrg)+"_"+LSTR(SECONDS())+".SQL"

    // ya existe no debe crearla nuevamente, si tiene tablas
    IF oDp:oMySqlCon:ExistDb(cDbDes)

       oDp:oMySqlCon:CreateDB(cDbDes)
       oDb:=OpenOdbc(cDbDes)

       IF !Empty(oDb:GetTables())
          RETURN .T.
       ENDIF

    ENDIF

    // 03/10/2023 genera incidencia por //mysqldump: unknown variable 'ignre-table=DPSGEV60.view_dplibinvdet_mes'
    AEVAL(aVistas,{|a,n| cMemo:=cMemo+IF(Empty(cMemo),""," ")+"--ignore-table="+cDbOrg+".view_"+lower(ALLTRIM(a[1]))})
    cMemo:=STRTRAN(cMemo,"ignre-table","ignore-table")

    ferase(cFileOrg)

    cComand:="MYSQL\mysqldump -C --opt "+CRLF+;
             " --add-drop-database  "+CRLF+;
             " --single-transaction "+CRLF+;
             " --skip-lock-tables   "+CRLF+;
             " --lock-tables=false  "+CRLF+;
             " --host="+oDp:cIp+" "  +CRLF+;
             " --no-data "+CRLF+;
             cMemo+;
             " --port="+LSTR(oDp:nPort)+" "+CRLF+;
             " --default-character-set=utf8 "+CRLF+;
             " --max_allowed_packet=512M "+CRLF+;
             "-B "+cDbOrg+;
             " -e "+;
             " -f "+;
             IF(Empty(cPass),""," --password="+ALLTRIM(cPass))+;
             " --user="+ALLTRIM(cLogin)+IIF(.F.," -t ","")+" -e > "+cFileTmp // cFileOrg

   cComand:=STRTRAN(cComand,CRLF,"") 
   DPWRITE(cBat,cComand)

   COPY FILE (cBat) TO ("RUNMYSQLDUMP.BAT")
 
   CursorWait()

   MsgRun("Generando Script "+cFileOrg,"Por favor espere",{|| WaitRun(cBat,0)})

   // ? FSIZE(cFileTmp),FILE(cFileTmp),cFileOrg

   IF FSIZE(cFileTmp)=0
      MsgMemo("No fué posible Crear el SCRIPT  "+cFileTmp)
   ENDIF

   // quitar CREATE BASE
   // nAt  :=AT("VIEW_",cMemo)

   cMemo:=MemoRead(cFileTmp)
   nAt  :=AT("VIEW_",cMemo)

   IF nAt=0
      nAt  :=AT("view_",cMemo)
   ENDIF

   IF nAt>0
      cMemo:=LEFT(cMemo,nAt)
      cMemo:=STRTRAN(cMemo,cDbOrg,cDbDes)
   ENDIF

   IF AT(cDbOrg,cMemo)>0
      cMemo:=STRTRAN(cMemo,cDbOrg,cDbDes)
      cMemo:=STRTRAN(cMemo,LOWER(cDbOrg),cDbDes)
   ENDIF

   /*
   // QUITAR CREATE BD
   */
   nAt  :=AT("USE ",cMemo)

   IF nAt>0
      cMemo:=SUBS(cMemo,nAt,LEN(cMemo))
      cMemo:=[SET FOREIGN_KEY_CHECKS=0 ;]+CRLF+cMemo
   ENDIF

   // Agregar las Vistas en el Script 
   cVistas:=""
   IF lViewJoin
     cFileView:=EJECUTAR("DPCREAVIEWFROMSCRIPT",cDbOrg)
     cVistas  :=MemoRead(cFileView)
   ENDIF

   // Vista Agregada la creación de las Tablas
   cMemo:=cMemo+CRLF+cVistas

   DPWRITE(cFileOrg,cMemo)
   cFileDes:="TEMP\"+cDbDes+".SQL"
   DPWRITE(cFileDes,cMemo)

   IF !oDp:oMySqlCon:ExistDb(cDbDes)
     oDp:oMySqlCon:CreateDB(cDbDes)
   ENDIF

   cFileLog:=oDp:cBin+"TEMP\MYSQL_"+cDbDes+".LOG"

   IF !FILE(cFileOrg)

      MsgMemo("No Existe "+cFileOrg)

    ELSE

      IF !FILE(oDp:cBin+"mysql\mysql.exe ")
         MsgMemo("Requiere Programa "+oDp:cBin+"mysql\mysql.exe "+CRLF+"La BD "+cDbDes+CRLF+;
                 " será creada mediante el Diccionario de Datos","mysql.exe No Encontrado")
      ENDIF

      cComand:=oDp:cBin+"mysql\mysql.exe "+;
               cDbDes+;
               " < "+cFileOrg+""+;
               " -u"+ALLTRIM(cLogin)+" "+;
               IF(Empty(cPass),"","-p"+ALLTRIM(cPass ))+" "+;
               " --host="+oDp:cIp+" "+;
               " --port="+LSTR(oDp:nPort)+;
               " > "+cFileLog

    ENDIF

    dpwrite(cBat,cComand)

    CursorWait()

    MsgRun("Ejecutando Script "+cFileOrg,"Creando Base de Datos "+cDbDes+" tardará varios minutos",{|| WaitRun(cBat,0)})

    cMemo:=Memoread(cFileLog)

    IF "ERROR"$cMemo
      MsgMemo(cMemo,"Incidencia en la Creación de la Base de Datos"+cDbDes)
    ENDIF

    EJECUTAR("ADDCLONE",cDbOrg,cDbDes) // evita revisar el release

    cBdChk  :=SQLGET("DPEMPRESA","EMP_FCHCHK,EMP_TABUPD","EMP_BD"+GetWhere("=",cDbOrg))
    cRelease:=DPSQLROW(2)
    SQLUPDATE("DPEMPRESA",{"EMP_FCHCHK","EMP_TABUPD"},{cBdChk,cRelease},"EMP_BD"+GetWhere("=",cDbDes))

    // SQLDELETE("DPEMPRESA","EMP_TABUPD",oDp:cBdRelease,"EMP_BD"+GetWhere("=",cDbDes))

RETURN .T.
// EOF
