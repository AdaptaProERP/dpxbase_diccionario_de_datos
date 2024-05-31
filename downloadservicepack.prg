// Programa   : DOWNLOADSERVICEPACK
// Fecha/Hora : 02/11/2023 11:57:00
// Propósito  : Descargar desde AdaptaPro Server
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oMemo)
   LOCAL cUrl,cSaveAs,cId
   LOCAL I,aZip:={},cFileZip,cFileZis:="",cData:="",aLineSrv:={},aLineLoc:={},lExe:=.F.
   LOCAL nTimeIni:=SECONDS()
   LOCAL aFiles  :=DIRECTORY(oDp:cBinExe)
   LOCAL cFile   :=Lower(cFileName(oDp:cBinExe))
   LOCAL cDir    :=Lower(cFileNoExt(cFileName(oDp:cBinExe)))

   IF !Empty(aFiles)
     // Tamaño del binario Actual, debe ser comparado con el Tamaño del binario en el Servidor
     cFileZis:=LSTR(aFiles[1,2])+","+DTOS(aFiles[1,3])+","+aFiles[1,4]
     aLineLoc:={aFiles[1,2],DTOS(aFiles[1,3]),aFiles[1,4]}
   ENDIF

   CursorWait()

   cFile:=cFile+".txt"

   /*
   // Valida si el programa binario a cambiado
   */
   // cUrl   :="http://191.96.151.60/~ftp16402/"+cDir+"/"+cFile
   cUrl   :=oDp:cUrlDownLoad+cDir+"/"+cFile
   cSaveAs:=oDp:cBin+"temp\"+cFile
   aFiles :={}

   ferase(cSaveAs)
   URLDownLoad(cUrl, cSaveAs)

   cData:=MemoRead(cSaveAs)
   IF !Empty(cData)
      aLineSrv:=_VECTOR(cData,",")
   ENDIF

   // uso interno de AdaptaPro
   IF "ADAPTAPRO"$UPPER(oDp:cBinExe)
      AADD(aFiles,"adaptapro.exe")
      lExe:=.T.
   ENDIF

   // Comparamos la fecha del binario, si el binario local es inferior al binario del servidor debera ser descargado
   IF LEN(aLineSrv)=LEN(aLineLoc) .AND. ( aLineSrv[1]<>aLineLoc[1] .OR. aLineSrv[2]<>aLineLoc[2] .OR. aLineSrv[3]<>aLineLoc[3])

      IF (aLineSrv[2]+aLineSrv[3])>(aLineLoc[2]+aLineLoc[3])
        // Binario del Servidor es Mayor que el Servidor Local
        cFile   :=Lower(cFileName(oDp:cBinExe))
        AADD(aFiles,cFile         )
        lExe:=.T.
      ENDIF
   ENDIF

   cFile   :=Lower(cFileName(oDp:cBinExe))

   AADD(aFiles,"dpxbase.zip" )
   AADD(aFiles,"forms.zip"   )
   AADD(aFiles,"dpvistas.zip")
   AADD(aFiles,"dpstruct.zip")
   AADD(aFiles,"bitmaps.zip" )
   AADD(aFiles,"dpprocesos.zip" )
   AADD(aFiles,"dptablas.zip" )
   AADD(aFiles,"dpreportes.zip" )
   AADD(aFiles,"crystal.zip" )
   AADD(aFiles,"cmd.zip" )
   AADD(aFiles,"dpctas.zip" )
   AADD(aFiles,"dpimprxls.zip" )
   AADD(aFiles,"dpsgev60.zip" )

   IF(ValType(oMemo)="O",oMemo:Append("Descargando "+CRLF+oDp:cUrlDownLoad+cDir+CRLF),NIL)
   IF(ValType(oMemo)="O",oMemo:Append("-----------"+CRLF),NIL)

   FOR I=1 TO LEN(aFiles)

    // cUrl   :="http://191.96.151.60/~ftp16402/"+cDir+"/"+aFiles[I]
    cUrl   :=oDp:cUrlDownLoad+cDir+"/"+aFiles[I]

    IF "EXE"$cFileExt(aFiles[I])

      IF "ADAPTAPRO"$UPPER(oDp:cBinExe)
        cSaveAs:=oDp:cBin+"bin\adaptapro.exe"
      ELSE
        cSaveAs:=oDp:cBin+"bin\"+aFiles[I]
      ENDIF

    ELSE
      cSaveAs:=oDp:cBin+"temp\"+aFiles[I]
    ENDIF

    // ? I,CLPCOPY(cUrl),cSaveAs

    IF(ValType(oMemo)="O",oMemo:Append("  "+aFiles[I]+CRLF),NIL)

    //  CursorWait()
    ferase(cSaveAs)
    URLDownLoad(cUrl, cSaveAs)

    IF FILE(cSaveAs)
      AADD(aZip,cSaveAs)
    ENDIF

    // SysRefresh(.T.)

   NEXT I

   IF(ValType(oMemo)="O",oMemo:Append("Descomprimiendo "+CRLF),NIL)
   IF(ValType(oMemo)="O",oMemo:Append("---------------"+CRLF),NIL)

   // Descomprimir
   FOR I=1 TO LEN(aZip)

      cDir    :=""
      cFileZip:=aZip[I]

      IF "dpxbase"$cFileZip
         cDir:=oDp:cBin+"dpxbase\"
      ENDIF

      IF "forms"$cFileZip
         cDir:=oDp:cBin+"forms\"
      ENDIF

      IF "bitmaps"$cFileZip
         cDir:=oDp:cBin+"bitmaps\"
      ENDIF

      IF "struct"$cFileZip
         cDir:=oDp:cBin+"struct\"
      ENDIF

      IF "dpvistas"$cFileZip
         cDir:=oDp:cBin+"dpvistas\"
      ENDIF

      IF "dpprocesos"$cFileZip
         cDir:=oDp:cBin+"datadbf\"
      ENDIF

      IF "dptablas"$cFileZip
         cDir:=oDp:cBin+"datadbf\"
      ENDIF

      IF "dpreportes"$cFileZip
         cDir:=oDp:cBin+"datadbf\"
      ENDIF

      IF "dpimprxls"$cFileZip
         cDir:=oDp:cBin+"datadbf\"
      ENDIF
  
      IF "cmd"$cFileZip
         cDir:=oDp:cBin+"cmd\"
      ENDIF

      IF "dpctas"$cFileZip
         cDir:=oDp:cBin+"dpctas\"
      ENDIF

      // crear empresa
      IF "dpsgev60"$cFileZip
         cDir:=oDp:cBin+"dpsgev60\"
      ENDIF

      IF !Empty(cDir)
         HB_UNZIPFILE( cFileZip , {|| nil }, .t., NIL, cDir , NIL )
         IF(ValType(oMemo)="O",oMemo:Append("  "+cFileZip+" en "+cDir+CRLF),NIL)
      ENDIF

   NEXT I

   // Crear los nuevos campos
   IF(ValType(oMemo)="O",oMemo:Append("Concluido"+CRLF),NIL)
   IF(ValType(oMemo)="O",oMemo:Append("---------"+CRLF),NIL)

   nT1:=SECONDS()
   IF(ValType(oMemo)="O",oMemo:Append("Actualización realizada en "+LSTR(SECONDS()-nTimeIni)+" Segundos "+CRLF),NIL)

   // EJECUTAR("DPLOADCNF")
   // oDp:aScripts, todos los script en Memoria, necesario resetearlos
   IF(ValType(oMemo)="O",oMemo:Append("Actualización definiciones de Importación desde Excel "+CRLF),NIL)

   EJECUTAR("DPIMPRXLS_FROMDBF") // Actualización definiciones desde EXCEL

   ShutDownScr("DPINIADDFIELD_ID")
   ShutDownScr("DPINIADDFIELD")

   cId:=EJECUTAR("DPINIADDFIELD_ID")
   IF(ValType(oMemo)="O",oMemo:Append("Actualizando diccionario de datos "+CRLF),NIL)

   EJECUTAR("DELDIRAPL",.F.)
   EJECUTAR("DPINIADDFIELD")     // Actualización del Diccionario de Datos

   IF lExe
     MsgMemo("Programa Binario "+cFile+" fué Actualizado",oDp:cSys+" será reiniciado")
   ENDIF
 
RETURN .T.
// EOF
