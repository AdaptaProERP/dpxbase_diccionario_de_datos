// Programa   : DPCREAVIEWFROMSCRIPT
// Fecha/Hora : 09/10/2023 18:43:35
// Propósito  : Crear Vistas desde Script
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDbOrg,cDbDes,lRun)
  LOCAL cMemo   :="",nAt,I,cTable,cVista,nAt
  LOCAL aVistas :={},cVistas:="",cFileView,cSql,aTables,oDb,nContar:=0,aLine:={},lLoop:=.F.,aNew:={}
  LOCAL cDir    :="DP"+oDp:cType+"V"+STRZERO(oDp:nVersion*10,2)
  LOCAL cFileOrg:=lower(oDp:cBin+cDir+"\"+cDir+".SQL")
  LOCAL cFileLog:=oDp:cBin+"TEMP\MYSQL_"+LSTR(SECONDS())+".LOG"
  LOCAL cFileMem:="MYSQL.MEM"
  LOCAL cBat    :="RUNVIEW.BAT"
  LOCAL _MycPass:="",_MycLoging:="",cPass,cLogin,cComand,cMemo


  DEFAULT cDbOrg:="DP"+oDp:cType+"V"+STRZERO(oDp:nVersion*10,2)

  /*
  // Generar sentencia de las Vistas
  */
  oDb    :=OpenOdbc(cDbOrg)

  aVistas:={}
  AEVAL(oDp:aVistas,{|a,n| IF(LEFT(a[3],1)="<",AADD(aVistas,a[1]),NIL)})

/*
  aVistas:=ACLONE(oDb:aTables)
  ADEPURA(aVistas,{|a,n| !"VIEW_"$UPPE(a)})
  AEVAL(aVistas,{|a,n| aVistas[n]:=UPPER(aVistas[n]),;
                        aVistas[n]:=STRTRAN(aVistas[n],"VIEW_","")})
*/

  // Vistas con vistas concatenadas
  aVistas:=ASQL([ SELECT CONCAT("VIEW_",VIS_VISTA) AS VIS_VISTA,VIS_DEFINE FROM DPVISTAS WHERE ]+GetWhereOr("VIS_VISTA",aVistas)+;
                [ AND VIS_DEFINE LIKE "%VIEW_%"] )

  AEVAL(aVistas,{|a,n| aVistas[n,1]:=ALLTRIM(a[1])})
  AEVAL(aVistas,{|a,n| aVistas[n,2]:=STRTRAN(a[2],CRLF,CRLF)})

  WHILE .T.

    WHILE nContar++<LEN(aVistas)
      
      cVista :=aVistas[nContar,1]
      cSql   :=aVistas[nContar,2]
      aTables:=EJECUTAR("SQL_ATABLES",UPPER(cSql))

      ADEPURA(aTables,{|a,n| !LEFT(a,6)="VIEW_"})

      IF LEN(aTables)>0

        FOR I=1 TO LEN(aTables)

          nAt:=ASCAN(aVistas,{|a,n| ALLTRIM(a[1])==ALLTRIM(aTables[I])})

          // La vista esta en la siguiente lista, sera removida del puesto y agregada antes de nContar
          IF nAt>nContar
             aLine:=ACLONE(aVistas[nAt])
             ARREDUCE(aVistas,nAt)
             AADD(aNew,ACLONE(aLine))
          ENDIF

       NEXT I

     ENDIF

    ENDDO

    IF Empty(aNew)
       EXIT
    ENDIF

    AEVAL(aVistas,{|a,n| AADD(aNew,ACLONE(a))})

    aVistas:=ACLONE(aNew)
    nContar:=0
    aNew   :={}

  ENDDO

  //  ViewArray(aVistas,NIL,.F.)

  /*
  // VISTAS QUE GENERAN LAS VISTAS CONCATENADAS
  */

/*
  aNew:=ACLONE(oDb:aTables)

  ADEPURA(aNew,{|a,n| !"VIEW_"$UPPE(a)})

  AEVAL(aNew,{|a,n| aNew[n]:=UPPER(aNew[n]),;
                    aNew[n]:=STRTRAN(aNew[n],"VIEW_","")})
*/

  aNew:={}
  AEVAL(oDp:aVistas,{|a,n| IF(LEFT(a[3],1)="<",AADD(aNew,a[1]),NIL)})

  /*
  // Vistas sin Vistas Concatenas son creadas inicialmente para luego crear las vistas con vistas concatenadas
  */
  aNew:=ASQL([ SELECT CONCAT("VIEW_",VIS_VISTA) AS VIS_VISTA,VIS_DEFINE FROM DPVISTAS WHERE ]+GetWhereOr("VIS_VISTA",aNew)+;
             [ AND VIS_DEFINE NOT LIKE "%VIEW_%"] )

  AEVAL(aVistas,{|a,n| AADD(aNew,a)})
  aVistas:=ACLONE(aNew)

  cVista:=""

  FOR I=1 TO LEN(aVistas)

    cSql:=aVistas[I,2]

    cSql:=STRTRAN(cSql,CRLF,"")              
    cSql:=STRTRAN(cSql," FROM"," FROM "+CRLF   )
    cSql:=STRTRAN(cSql," SUM("  ,CRLF+" SUM("  )
    cSql:=STRTRAN(cSql," INNER ",CRLF+" INNER ")
    cSql:=STRTRAN(cSql," GROUP BY ",CRLF+" GROUP BY ")
    cSql:=STRTRAN(cSql," ORDER BY ",CRLF+" ORDER BY ")
    cSql:=EJECUTAR("WHERE_VAR",cSql)

    cSql:=" CREATE OR REPLACE VIEW  "+ALLTRIM(aVistas[I,1])+" AS "+CRLF+cSql+";"+CRLF+CRLF

    aVistas[I,2]:=cSql

    cVista:=cVista+cSql

  NEXT I

  IF !Empty(cDbDes)
     cVista:=" USE "+cDbDes+";"+CRLF+cVista
// ? cDbDes,LEFT(cVista,1024)
  ENDIF

  // Primera Vistas sobre las vistas
  cFileView:=STRTRAN(cFileOrg,".","_VIEW.")
  DPWRITE(cFileView,cVista)

  IF lRun 

     DEFAULT cDbDes:="DPSGEV60_CLUB"

     REST FROM (cFileMem) ADDI

     cPass  :=ENCRIPT(_MycPass  ,.F.)
     cLogin :=ENCRIPT(_MycLoging,.F.)

     cComand:=oDp:cBin+"mysql\mysql.exe "+;
              cDbDes+;
              " < "+cFileView+""+;
              " -u"+ALLTRIM(cLogin)+" "+;
              IF(Empty(cPass),"","-p"+ALLTRIM(cPass ))+" "+;
              " --host="+oDp:cIp+" "+;
              " --port="+LSTR(oDp:nPort)+;
              " > "+cFileLog
   
    dpwrite(cBat,cComand)

    CursorWait()

    MsgRun("Ejecutando Script "+cFileView,"Creando Vistas en la Base de Datos "+cDbDes+" tardará varios minutos",{|| WaitRun(cBat,0)})

    cMemo:=Memoread(cFileLog)

    IF "ERROR"$cMemo
      MsgMemo(cMemo,"Incidencia en la Creación de las Vistas en la  Base de Datos"+cDbDes)
    ENDIF

  ENDIF

RETURN cFileView
//
