// Programa   : DPCREABDFROMSCRIPT
// Fecha/Hora : 07/07/2023 23:43:00
// Propósito  : Crear Base de Datos desde DPSGEV60\DPSGEV60.SQL 
//              Sino está es generador desde mysqldump.exe solo estructura de datos
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
    LOCAL aVistas :=ACLONE(oDp:aVistas)

    ADEPURA(aVistas,{|a,n| LEFT(a[3],1)="."})


// aVistas:=ADEPURA(aVistas,{|a,n| oDbC:FILE(a[2])})
// ViewArray(aVistas)
// ? cMemo
// RETURN 
// RETURN .T.

    REST FROM (cFileMem) ADDI

    // cFileOrg:=strtran(cFileOrg,"\","/")

    cPass  :=ENCRIPT(_MycPass  ,.F.)
    cLogin :=ENCRIPT(_MycLoging,.F.)

    DEFAULT cDbDes:="SGEV60_TEST",;
            cDbOrg:="DP"+oDp:cType+"V"+STRZERO(oDp:nVersion*10,2)


    AEVAL(aVistas,{|a,n| cMemo:=cMemo+IF(Empty(cMemo),""," ")+"--ignore-table="+cDbOrg+".view_"+lower(ALLTRIM(a[1]))})

    ferase(cFileOrg)
? cDbOrg,"DEBO GENERARLO NUEVAMENTE SOLO CON LA ESTRUCTURA",cFileOrg

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
            " --user="+ALLTRIM(cLogin)+IIF(.F.," -t ","")+" -e > "+cFileOrg

   cComand:=STRTRAN(cComand,CRLF,"") 
   DPWRITE(cBat,cComand)
 
   CursorWait()

   MsgRun("Generando Script "+cFileOrg,"Por favor espere",{|| WaitRun(cBat,0)})

RETURN .T.

   cMemo   :=MEMOREAD(cFileOrg)
   nAt     :=AT(cDbOrg,cMemo)
   cMemo   :=STRTRAN(cMemo,cDbOrg,cDbDes)
   cFileDes:="TEMP\"+cDbDes+".SQL"

    DPWRITE(cFileDes,cMemo)

    IF !oDp:oMySqlCon:ExistDb(cDbDes)
      oDp:oMySqlCon:CreateDB(cDbDes)
    ENDIF

    // D:\SYSTEMDB\1206\MariaDb1011\bin\mysql alprogeneirl < D:\PRGS\SIAE\BIN\alprogen.sql -u root -pqazwsxedc
    // https://fivetechsupport.com/forums/viewtopic.php?f=6&t=43740&p=264063&sid=76f8be83ba04affab1aa7a643b96a306#p264063

    IF !FILE(cFileOrg)

      MsgMemo("No Existe "+cFileOrg)

    ELSE

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

    cFileLog:=Memoread(cFileLog)

    IF "ERROR"$cMemo
      MsgMemo(cMemo,"Incidencia en la Creación de la Base de Datos"+cDbDes)
    ENDIF

IF .F.

   cFileView:=EJECUTAR("DPVISTASTOSCRIPT",NIL,.F.,.F.)

   MsgRun("Ejecutando Script "+cFileDes,"Creando Base de Datos "+cDbDes,{|| WaitRun(cBat,0)})

   IF FILE(cFileView)

     cComand:="mysql\mysql.exe "+;
              "-u"+ALLTRIM(cLogin)+" "+;
              IF(Empty(cPass),"","-p"+ALLTRIM(cPass ))+" "+;
              " --host="+oDp:cIp+" "+;
              " --port="+LSTR(oDp:nPort)+;
              " "+cDbDes+""+;
              "< "+cFileView+" > "+cFileLog


     MemoWrit(cBat,cComand)

     MsgRun("Ejecutando Script "+cFileView,"Creando Vistas "+cDbDes,{|| WaitRun(cBat,0)})

   ENDIF

ENDIF

   EJECUTAR("ADDCLONE",cDbOrg,cDbDes) // evita revisar el release

? "REVISAR SI FUE CREADO LOS ARCHIVOS ADD PARA EVITAR REPETIR RELEASE"

   cBdChk:=SQLGET("DPEMPRESA","EMP_FCHCHK","EMP_BD"+GetWhere("=",cDbOrg))
   SQLUPDATE("DPEMPRESA","EMP_FCHCHK",cBdChk,"EMP_BD"+GetWhere("=",cDbDes))

   // SQLDELETE("DPEMPRESA","EMP_TABUPD",oDp:cBdRelease,"EMP_BD"+GetWhere("=",cDbDes))

RETURN .T.
// EOF
