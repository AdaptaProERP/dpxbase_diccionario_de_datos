// Programa   : ODBCLIST
// Fecha/Hora : 26/02/2013 17:46:40
// Propósito  : Mostrar Listas de Tablas ODBC
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDsn,cLogin,cUsuario,cTabla,lFields)

    LOCAL aDsn:=OdbcDsnEntries()

    IF !Empty(cDsn)
      RETURN VERCAMPOS(cDsn,cTabla,cUsuario,cLogin,lFields)
    ENDIF

    IF Empty(aDsn)
       MensajeErr("No Hay DSN definidos")
       RETURN NIL
    ENDIF

    ViewData(aDsn,"DSN definidos")

RETURN

FUNCTION ViewData(aData,cTitle,lTodos)
   LOCAL oCol,oFont,oFontB,I

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   oVerDsn:=DPEDIT():New(cTitle,"ODBCLIST.EDT","oVerDsn",.T.)

// DpMDI(cTitle,"oVerDsn",NIL,.T.)

   oVerDsn:lMsgBar :=.F.
   oVerDsn:cNombre :=""
   oVerDsn:lTodos  := lTodos

   oVerDsn:nClrPane1:=16774120
   oVerDsn:nClrPane2:=16772829
   oVerDsn:nClrText :=0

   oVerDsn:oBrw:=TXBrowse():New( oVerDsn:oDlg )
   oVerDsn:oBrw:SetArray( aData, .F. )

   oVerDsn:oBrw:SetFont(oFont)

   oVerDsn:oBrw:lHScroll    := .T.
   oVerDsn:oBrw:nHeaderLines:= 1
   oVerDsn:oBrw:lFooter     :=.F.

   oCol:=oVerDsn:oBrw:aCols[1]   
   oCol:cHeader      :="Dsn"
   oCol:nWidth       :=390

   oVerDsn:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oVerDsn:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oVerDsn:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oVerDsn:nClrPane1, oVerDsn:nClrPane2 ) } }

   oVerDsn:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oVerDsn:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   AEVAL(oVerDsn:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oVerDsn:oBrw:bLDblClick:={||oVerDsn:VERTABLAS(oVerDsn:oBrw:aArrayData[oVerDsn:oBrw:nArrayAt])}

   oVerDsn:oBrw:CreateFromCode()

   oVerDsn:Activate({||oVerDsn:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oBtnCal
   LOCAL oDlg   :=oVerDsn:oDlg

   oVerDsn:oBrw:GoTop(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oVerDsn:VERTABLAS(oVerDsn:oBrw:aArrayData[oVerDsn:oBrw:nArrayAt])
              
   oBtn:cToolTip:="Ver Tablas"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oVerDsn:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oVerDsn:oBrw,oVerDsn:cTitle,oVerDsn:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oVerDsn:oBrw:GoTop(),oVerDsn:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oVerDsn:oBrw:GoBottom(),oVerDsn:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oVerDsn:Close()

  oVerDsn:oBrw:SetColor(0,oVerDsn:nClrPane1)
  oBar:SetColor(CLR_BLACK,15724527 )

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


RETURN .T.

FUNCTION VERTABLAS(cDsn)
  LOCAL oOdbc,aTablas,cLogin,cPass
  LOCAL oCol,oFont,oFontB,I,cTitle
 
  cDsn:=ALLTRIM(cDsn)

  cTitle:="Tablas del DSN :"+cDsn

  oODbc:=TODBC():New(cDsn, cLogin, cPass )
  aTablas:=oODbc:gettables()
  oOdbc:End()

  IF Empty(aTablas)
     MensajeErr("No hay Tablas en el DSN")
     RETURN .F.
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  DPEDIT():New(cTitle,"ODBCVERTABLAS.EDT","oVerTablas",.T.)

  oVerTablas:lMsgBar :=.F.
  oVerTablas:cNombre :=""
  oVerTablas:cDsn    :=cDsn

  oVerTablas:oBrw:=TXBrowse():New( oVerTablas:oDlg )
  oVerTablas:oBrw:SetArray( aTablas, .F. )

  oVerTablas:oBrw:SetFont(oFont)

  oVerTablas:oBrw:lHScroll    := .T.
  oVerTablas:oBrw:nHeaderLines:= 1
  oVerTablas:oBrw:lFooter     :=.F.

  oCol:=oVerTablas:oBrw:aCols[1]   
  oCol:cHeader      :="Tabla"
  oCol:nWidth       :=400

  oVerTablas:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oVerTablas:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oVerDsn:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,14155775, 9240575 ) } }

  oVerTablas:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oVerTablas:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  AEVAL(oVerTablas:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})


  oVerTablas:oBrw:CreateFromCode()

//  oVerTablas:oWnd:oClient := oVerTablas:oBrw

  oVerTablas:Activate({||oVerTablas:ViewDatBar2()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar2()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oVerTablas:oDlg,oBtnCal

   oVerTablas:oBrw:GoTop(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oVerTablas:VERCAMPOS(oVerTablas:cDsn,oVerTablas:oBrw:aArrayData[oVerTablas:oBrw:nArrayAt])
              
   oBtn:cToolTip:="Ver Tablas"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oVerTablas:TESTOPENTABLE(oVerTablas:cDsn,oVerTablas:oBrw:aArrayData[oVerTablas:oBrw:nArrayAt])
              
   oBtn:cToolTip:="Ver con OpenTable"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oVerTablas:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oVerTablas:oBrw,oVerTablas:cTitle,oVerTablas:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oVerTablas:oBrw:GoTop(),oVerTablas:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oVerTablas:oBrw:GoBottom(),oVerTablas:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oVerTablas:Close()

  oVerTablas:oBrw:SetColor(0,14155775)
  oBar:SetColor(CLR_BLACK,15724527 )

// 14155775, 9240575

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


RETURN .T.

FUNCTION VERCAMPOS(cDsn,cTabla,cUsuario,cLogin,lFields)

  LOCAL oOdbc,aTablas,cLogin,cPass,oTable,aFields:={}
  LOCAL oCol,oFont,oFontB,I,cTitle,aData:={},cSql

  DEFAULT lFields:=.F.


  CursorWait()

  cDsn  :=ALLTRIM(cDsn)
  cTitle:="Contenido de Tabla :"+cTabla

  oODbc:=TODBC():New(cDsn, cLogin, cPass )

  IF !lFields
    oOdbc:lDateAsStr:=.T.
  ENDIF

  cSql   :="SELECT * FROM "+cTabla //+IF(lFields," WHERE 1=0 ","")

  oTable :=oOdbc:Query(cSql)
  aData  :=ACLONE(oTable:aFill())
  aFields:=ACLONE(oTable:aFields)

  oDp:aData:=ACLONE(aData)
  oTable:End()
  oOdbc:End()

  IF lFields
    RETURN ACLONE(aFields)
  ENDIF


  IF Empty(aData)
     MensajeErr("Tabla no Tiene Datos")
     RETURN .F.
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 

  DPEDIT():New(cTitle,"ODBCVERDATA.EDT","oVerData",.T.)

//  DPMDI():New(cTitle,"ODBCVERDATA.EDT","oVerData",.T.)

  oVerData:lMsgBar :=.F.
  oVerData:cNombre :=""
  oVerData:cDsn    :=cDsn
  oVerData:cTabla  :=cTabla

  oVerData:oBrw:=TXBrowse():New( oVerData:oDlg )
  oVerData:oBrw:SetArray( aData, .F. )

  oVerData:oBrw:SetFont(oFont)

  oVerData:oBrw:lHScroll    := .T.
  oVerData:oBrw:nHeaderLines:= 1
  oVerData:oBrw:lFooter     :=.F.

  FOR I=1 TO LEN(aFields)
    oCol:=oVerData:oBrw:aCols[I]
    oCol:cHeader:=aFields[I,1]
  NEXT I

  oVerData:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oVerData:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oVerDsn:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,14087148, 11790521 ) } }

//  oVerData:oWnd:oClient := oVerData:oBrw

  oVerData:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oVerData:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  AEVAL(oVerData:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oVerData:oBrw:CreateFromCode()

  oVerData:Activate({||oVerData:ViewDatBar3()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar3()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oVerData:oDlg,oBtnCal

   oVerData:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oVerData:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oVerData:oBrw,oVerData:cTitle,oVerData:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oVerData:oBrw:GoTop(),oVerData:oBrw:Setfocus())

  oBtn:cToolTip:="Inicio de la Lista"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oVerData:oBrw:GoBottom(),oVerData:oBrw:Setfocus())

  oBtn:cToolTip:="Final de la Lista"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oVerData:Close()

  oVerData:oBrw:SetColor(0,14155775)
  oBar:SetColor(CLR_BLACK,15724527 )

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


RETURN .T.

FUNCTION TESTOPENTABLE(cDsn,cTabla,cUsuario,cLogin,lFields)

  LOCAL oOdbc,aTablas,cLogin,cPass,oTable,aFields:={}
  LOCAL oCol,oFont,oFontB,I,cTitle,aData:={},cSql
  LOCAL oCursor

  DEFAULT lFields:=.F.

  CursorWait()

  cDsn  :=ALLTRIM(cDsn)
  cTitle:="Contenido Mediante OpenTable :"+cTabla

  oODbc:=TODBC():New(cDsn, cLogin, cPass )

  cSql   :="SELECT * FROM "+cTabla

  oTable:=OpenTable(cSql,.T.,oOdbc,.F.)
  oTable:Browse()
  oTable:End()
  oOdbc:End()

RETURN NIL


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oVerDsn)
// EOF
