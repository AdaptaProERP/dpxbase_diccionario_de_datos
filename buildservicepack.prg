// Programa   : BUILDSERVICEPACK
// Fecha/Hora : 02/11/2023 10:52:49
// Propósito  : Crear el Service Pack
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cFileZip,cDir,cPass:=NIL,aForms:={},cFileZis:="",oTable
  LOCAL aFiles  :=DIRECTORY(oDp:cBinExe)
  LOCAL cFile   :=cFileName(oDp:cBinExe)
  LOCAL aFileBmp:={},I,cTable

  IF !Empty(aFiles)
    cFileZis:=LSTR(aFiles[1,2])+","+DTOS(aFiles[1,3])+","+aFiles[1,4]
  ENDIF

//  ViewArray(aFiles)
//
// ? oDp:cBinExe,cFileZis,cFile
// RETURN 


  cDir    :="servicepack"

  lMkDir(cDir)

  cFile:=cDir+"\"+cFile+".txt"

  DPWRITE(cFile,cFileZis)

  // CMD
  cFileZip:=oDp:cBin+cDir+"\cmd.zip"
  aFiles  :=DIRECTORY("cmd\*.txt")
  FERASE(cFileZip)

  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"cmd\"+a[1]})

  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  // dpxbase
  cFileZip:=oDp:cBin+cDir+"\dpxbase.zip"
  aFiles  :=DIRECTORY("DPXBASE\*.DXBX")
  FERASE(cFileZip)

  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"dpxbase\"+a[1]})
//  ViewArray(aFiles)

IF .T.
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  /*
  // CRYSTAL
  */
  aFiles  :=DIRECTORY(oDp:cBin+"\SERVICEPACK\CRYSTAL\*.rpt")
  cFileZip:=oDp:cBin+cDir+"\crystal.zip"

  ferase(cFileZip)
  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"SERVICEPACK\CRYSTAL\"+a[1]})

  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  /*
  // FORMS
  */
  aFiles  :=DIRECTORY("FORMS\*.LBX")
  AEVAL(aFiles,{|a,n| AADD(aForms,oDp:cBin+"forms\"+a[1])})

  aFiles  :=DIRECTORY("FORMS\*.EDT")
  AEVAL(aFiles,{|a,n| AADD(aForms,oDp:cBin+"forms\"+a[1])})

  aFiles  :=DIRECTORY("FORMS\*.SCG")
  AEVAL(aFiles,{|a,n| AADD(aForms,oDp:cBin+"forms\"+a[1])})

  aFiles  :=DIRECTORY("FORMS\*.BRW")
  AEVAL(aFiles,{|a,n| AADD(aForms,oDp:cBin+"forms\"+a[1])})

  cFileZip:=oDp:cBin+cDir+"\forms.zip"
  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aForms, 9,,.T., cPass, .F., .F. )



  // Diccionario de datos
  // Incluimos DPVISTAS\*.TXT que buscar cualquiera que sea requerida
  //  ViewArray(aForms)

  cFileZip:=oDp:cBin+cDir+"\dpvistas.zip"
  aFiles  :=DIRECTORY("dpvistas\*.txt")
  FERASE(cFileZip)

  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"dpvistas\"+a[1]})

  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  // Diccionario de datos
  // Incluimos DPVISTAS\*.TXT que buscar cualquiera que sea requerida
  //  ViewArray(aForms)

  cFileZip:=oDp:cBin+cDir+"\dpstruct.zip"
  aFiles  :=DIRECTORY("struct\*.txt")
  FERASE(cFileZip)

  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"struct\"+a[1]})

  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  cFileZip:=oDp:cBin+cDir+"\bitmaps.zip"
  AADD(aFileBmp,oDp:cBin+"bitmaps\AUDITORIAG.BMP")

  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFileBmp, 9,,.T., cPass, .F., .F. )

  FERASE(cDir+"\DOWNLOADSERVICEPACK.DXBX")
  COPY FILE ("DPXBASE\DOWNLOADSERVICEPACK.DXBX")  TO (cDir+"\DOWNLOADSERVICEPACK.DXBX")
  COPY FILE ("DPXBASE\DOWNLOADSERVICEPACKP.DXBX")  TO (cDir+"\DOWNLOADSERVICEPACKP.DXBX")


  COPY FILE (oDp:cBinExe) TO (cDir+"\"+oDp:cBinExe)

  // generar DPDATADBF
  // COPY FILE (oDp:cBinExe) TO (cDir+"\adaptapro.exe")
  oTable:=OpenTable("SELECT * FROM DPPROCESOS",.T.)
  oTable:CTODBF("datadbf\DPPROCESOS.DBF")
  oTable:End()

  oTable:=OpenTable("SELECT * FROM DPPROCESOSMEMO",.T.)
  oTable:CTODBF("datadbf\DPPROCESOSMEMO.DBF")
  oTable:End()

  cFileZip:=oDp:cBin+cDir+"\dpprocesos.zip"
  aFiles  :=DIRECTORY("datadbf\dpproce*.*")

  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"temp\"+a[1]})

  aFiles  :=ADEPURA(aFiles,{|a,n| "SQL"$UPPER(cFileExt(a))})

      
  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )
        
  // Reportes
  oTable:=OpenTable("SELECT * FROM DPREPORTES",.T.)
  oTable:CTODBF("datadbf\DPREPORTES.DBF")
  oTable:End()

  oTable:=OpenTable("SELECT * FROM DPGRUREP",.T.)
  oTable:CTODBF("datadbf\DPGRUREP.DBF")
  oTable:End()

  SQLUPDATE("dpimprxls","IXL_ALTER",.F.) // ninguno alterado para las actualizaciones
  oTable:=OpenTable("SELECT * FROM dpimprxls",.T.)
  oTable:CTODBF("datadbf\dpimprxls.DBF")
  oTable:End()



  // Reportes 13/12/2023
  aFiles  :={}
  cFileZip:=oDp:cBin+cDir+"\dpreportes.zip"
  AADD(aFiles,oDp:cBin+"datadbf\dpreportes.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpreportes.fpt")
  AADD(aFiles,oDp:cBin+"datadbf\dpgrurep.dbf")
  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  cFileZip:=oDp:cBin+cDir+"\dptablas.zip"
  aFiles  :={}
  AADD(aFiles,oDp:cBin+"datadbf\dpcampos.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dptablas.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dplink.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpindex.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpcamposop.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpmenu.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpbotbar.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpbrw.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpbrw.fpt")
  AADD(aFiles,oDp:cBin+"datadbf\dpvistas.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpvistas.fpt")
  AADD(aFiles,oDp:cBin+"datadbf\dpbrwclasifica.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpbrwclasifica.fpt")
  AADD(aFiles,oDp:cBin+"datadbf\dpaddon.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpaddon.fpt")
  AADD(aFiles,oDp:cBin+"datadbf\dpviewgru.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpviewgrurun.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpviewgrurun.fpt")

  TABLETODBF(aFiles)

//  AADD(aFiles,oDp:cBin+"datadbf\dpimprxls.dbf")
//  AADD(aFiles,oDp:cBin+"datadbf\dpimprxls.fpt")


  FERASE(cFileZip)

  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  cFileZip:=oDp:cBin+cDir+"\dpimprxls.zip"
  aFiles  :={}
  AADD(aFiles,oDp:cBin+"datadbf\dpimprxls.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpimprxls.fpt")

  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )


  cFileZip:=oDp:cBin+cDir+"\dpaddon.zip"
  aFiles  :={}
  AADD(aFiles,oDp:cBin+"datadbf\dpaddon.dbf")
  AADD(aFiles,oDp:cBin+"datadbf\dpaddon.fpt")

  FERASE(cFileZip)
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

ENDIF

  aFiles  :=DIRECTORY("dpctas\*.*")
  AEVAL(aFiles,{|a,n| aFiles[n]:=oDp:cBin+"dpctas\"+a[1]})
  AADD(aFiles,oDp:cBin+"dpctas\dpcta.xls")

  cFileZip:=oDp:cBin+cDir+"\dpctas.zip"
  HB_ZipFile( cFileZip, aFiles, 9,,.T., cPass, .F., .F. )

  COPY FILE ("respaldo\dpsgev60.zip")  TO (cDir+"\dpsgev60.zip")

  EJECUTAR("DPIMPRXLS_TO_PRG")

  EJECUTAR("DPPROCESOS_TO_PRG")


  ? "Concluido"
 
RETURN NIL

FUNCTION TABLETODBF(aFiles)
  LOCAL oTable,I,cTable

  FOR I=1 TO LEN(aFiles)

      cTable:=cFileNoPath(aFiles[I])

      IF cFileExt(cTable)="DBF"
         cTable:=cFileNoExt(cTable)
         OpenTable("SELECT * FROM "+cTable,.T.):CTODBF("DATADBF\"+cTable+".DBF")
      ENDIF

  NEXT I

RETURN 
// EOF

