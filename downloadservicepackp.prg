// Programa   : DOWNLOADSERVICEPACKP
// Fecha/Hora : 02/11/2023 15:46:01
// Propósito  : Descargar el programa que hace la actualización
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oMemo)
   LOCAL cUrl,cSaveAs
   LOCAL aFiles:={},I,aZip:={},cFileZip
   LOCAL nT1 :=SECONDS(),cPing,cIp:=oDp:cHttpDownLoad // "191.96.151.60"
   LOCAL cDir:=Lower(cFileNoExt(cFileName(oDp:cBinExe)))


   CursorWait()

   IF(ValType(oMemo)="O",oMemo:Append("Validando Conexión con "+cIp+CRLF),NIL)

   cPing:=EJECUTAR("GETPING",cIp,.F.)

// ? cPing

   IF "NO PUDO"$UPPER(cPing)

     IF ValType(oMemo)="O"
        oMemo:Append("No hay Conexión con "+cIp+CRLF)
     ELSE
        MsgMemo("No hay Conexión con "+cIP)
     ENDIF

     RETURN .F.

   ENDIF

   ShutDownScr("downloadservicepack")
   AADD(aFiles,"downloadservicepack.dxbx")
   AADD(aFiles,"downloadservicepackp.dxbx")


   IF(ValType(oMemo)="O",oMemo:Append("Descargando "+CRLF),NIL)
   IF(ValType(oMemo)="O",oMemo:Append("-----------"+CRLF),NIL)

   FOR I=1 TO LEN(aFiles)

    // cUrl   :="http://191.96.151.60/~ftp16402/"+cDir+"/"+aFiles[I]
    cUrl   :=oDp:cUrlDownLoad+cDir+"/"+aFiles[I]
    cSaveAs:=oDp:cBin+"dpxbase\"+aFiles[I]

    IF(ValType(oMemo)="O",oMemo:Append(" "+aFiles[I]+CRLF),NIL)

    CursorWait()
    ferase(cSaveAs)
    URLDownLoad(cUrl, cSaveAs)

//    IF FILE(cSaveAs) .AND. cFileExt(cSaveAs)=".ZIP"
//      AADD(aZip,cSaveAs)
//  ENDIF

    SysRefresh(.T.)

   NEXT I

RETURN .T.
// EOF
