// Programa   : BCVTASASINT
// Fecha/Hora : 16/08/2014 20:22:21
// Propósito  : Descargar Tasas de Interes desde BCV
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cUrl,cDir,nIni,lView,oMeter,cFileEjm)
   LOCAL cFile:=cFileEjm,aFiles:={},nT1:=SECONDS(),oFrm
   LOCAL oExcel,nLin:=1,nCol:=1,cValue,aData:={},I
   LOCAL cCol1,cCol2,cCol3,cCol4,cCol5,nVacio:=0,cAno:="",nAt,oTable,cWhere,dHasta
   LOCAL aMeses:={"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"}
   LOCAL cFile  :=oDp:cBin+"temp\"+cFileName(STRTRAN(cUrl,"/","\"))
   LOCAL cWeb,nAt,cIp:="",lResp:=.F.

   // http://www.bcv.org.ve/excel/1_3_18.xls
   // DEFAULT cUrl  :="https://www.bcv.org.ve/excel/1_3_18.xls",;

   DEFAULT cUrl    :="https://www.bcv.org.ve/sites/default/files/GEE - Tasas de Interes/1_3_18.xls",;
           cDir    :="C:\Documents and Settings\Administrador\Mis documentos\Downloads\",;
           lView   :=.F.,;
           nIni    :=1,;
           cFileEjm:=""

   cUrl  :=ALLTRIM(cUrl)
   cDir  :=ALLTRIM(cDir)
   nAt   :=RAT("/",cUrl)

   IF Empty(cFileEjm) .OR. !FILE(cFileEjm)

     cWeb  :=_VECTOR(UPPER(cUrl),"/")
     nAt   :=ASCAN(cWeb,"WWW.")

     IF nAt>0

       cWeb:=lower(cWeb[nAt])
       cIp :=GETHOSTBYNAME(cWeb)

       IF "0.0.0.0"$cIp
         MsgMemo("Sitio "+cWeb+" no Está disponible")
         RETURN .F.
       ENDIF

     ENDIF

    IF Empty(cFileEjm)

      cFile :=oDp:cBin+"temp\file"+lstr(seconds())+cFileName(STRTRAN(cUrl,"/","\"))
  
      FERASE(cFile)

      oFrm:=MSGRUNVIEW("Descargando Tasas de Interés desde BCV")

      DpMsgSetText("URL "+cUrl)

      URLDownloadToFile(0,cUrl,cFile,0,0 )

      IF !FILE(cFile)
        MsgMemo("No se pudo descargar "+cUrl)
        RETURN .F.
      ENDIF

     IF lView
       SHELLEXECUTE(oDp:oFrameDp:hWND,"open",cFile)
       RETURN .T.
     ENDIF

     DpMsgSetText("Importando Datos desde "+cFile)

  ELSE

   // Para Hacer Pruebas
   // cFile :=oDp:cBin+"temp\1_3_18.xls"
   cFile :=cFileEjm

  ENDIF

ENDIF

   IF !FILE(cFile)
       RETURN .F.
   ENDIF

   IF oFrm=NIL
     oFrm:=MSGRUNVIEW("Importando Tasas de Interes desde el BCV ")
   ENDIF



   oExcel := TExcelScript():New()
   oExcel:Open( cFile )

   nLin:= nIni

   WHILE nVacio<6

    nlin++
    nCol++
    uValue:=SPACE(100)
    cCol1:=oExcel:Get( nLin , 1 ,@cValue )
    cCol2:=oExcel:Get( nLin , 3 ,@cValue )
    cCol3:=oExcel:Get( nLin , 4 ,@cValue )
    cCol4:=oExcel:Get( nLin , 5 ,@cValue )
    cCol5:=oExcel:Get( nLin , 6 ,@cValue )

    IF Empty(cCol1)
       nVacio++
    ELSE

       nVacio:=0

       IF Empty(cCol2)
         cAno:=STRZERO(INT(CTOO(cCol1,"N")),4)
       ELSE
         cCol1:=UPPE(LEFT(cCol1,3))
         AADD(aData,{cAno,cCol1,cCol2,cCol3,cCol4,cCol5})
       ENDIF

    ENDIF

  ENDDO

  oExcel:End()
 
  SysRefresh(.T.)

  FOR I=1 TO LEN(aData)
     aData[I,1]:=STRZERO(YEAR(CTOO(aData[I,4],"D")),4)
  NEXT I

  // ViewArray(aData)

  aData[LEN(aData),2]:="JUN"
  // ViewArray(aData)


/*
 C001=INT_PRESTA,'N',006,2,'','PrÚstamos',0
 C002=INT_BANCA ,'N',006,2,'','Otras Tasas',0
 C003=INT_OTRO  ,'N',006,2,'','Tasa Bancaria',0
 C004=INT_TASA  ,'N',006,2,'','Prestaciones',0
 C005=INT_HASTA ,'D',008,0,'','Fecha',0
 C006=INT_GACETA,'C',008,0,'','Gaceta',0
 C007=INT_FCHGAC,'D',008,0,'','Fecha de la Gaceta',0
*/


  IF !oMeter=NIL
     oMeter:Settotal(LEN(aData))
  ELSE
     oFrm:FRMSETTOTAL(LEN(aData))
  ENDIF

  FOR I=1 TO LEN(aData)

     IF !oMeter=NIL
       oMeterR:Set(I)
     ENDIF

     IF I%5=0
        oFrm:FRMSET(I,.T.)
     ENDIF

     cAno  :=aData[I,1]
     nAt   :=ASCAN(aMeses,{|a,n| a=aData[I,2]})
     nAt   :=STRZERO(nAt,2)
     dhasta:=FCHFINMES("01/"+nAt+"/"+cAno)
     cWhere:="INT_HASTA"+GetWhere("=",dhasta)
     oTable:=OpenTable("SELECT * FROM NMTASASINT WHERE "+cWhere,.T.)

     IF oTable:RecCount()=0
        oTable:AppendBlank()
        oTable:cWhere:=""
     ENDIF

     oTable:Replace("INT_HASTA" ,dHasta)
     oTable:Replace("INT_GACETA",aData[I,2]) 
     oTable:Replace("INT_FCHGAC",aData[I,4])
     oTable:Replace("INT_TASA"  ,aData[I,5])
     oTable:Replace("INT_OTRO"  ,aData[I,6]) 
 
     oTable:Commit(oTable:cWhere)
     oTable:End()

  NEXT 

  SysRefresh(.T.)

  oFrm:FRMCLOSE()

RETURN LEN(aData)>0
// EOF

