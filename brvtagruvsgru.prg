// Programa   : BRVTAGRUVSGRU
// Fecha/Hora : 23/10/2023 10:53:45
// Propósito  : "Venta de Productos por Grupo"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cTendencia,cField)
   LOCAL aData,aFechas,cFileMem:="USER\BRVTAGRUVSGRU.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oVTAGRUVSGRU")="O" .AND. oVTAGRUVSGRU:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oVTAGRUVSGRU,GetScript())
   ENDIF

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"VIEW_DPGRUPO_VTA",.F.)
      EJECUTAR("VIEW_DPGRUPO_VTA")
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF

   cTitle:="Comparativo entre dos Periodos de Venta por Grupos de Productos" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD(""),;
           cTendencia   :=">"     ,;
           cField  :="GRU_CANTID"


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)

      cCodPar:=ATAIL(_VECTOR(cWhere,"="))

      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL,cCodSuc,dDesde,dHasta,cTendencia,cField,.F.)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oVTAGRUVSGRU

RETURN .T.


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oVTAGRUVSGRU","BRVTAGRUVSGRU.EDT")
// oVTAGRUVSGRU:CreateWindow(0,0,100,550)
   oVTAGRUVSGRU:Windows(0,0,aCoors[3]-160,MIN(536,aCoors[4]-10),.T.) // Maximizado

   oVTAGRUVSGRU:cCodSuc  :=cCodSuc
   oVTAGRUVSGRU:lMsgBar  :=.F.
   oVTAGRUVSGRU:cPeriodo :=aPeriodos[nPeriodo]
   oVTAGRUVSGRU:cCodSuc  :=cCodSuc
   oVTAGRUVSGRU:nPeriodo :=nPeriodo
   oVTAGRUVSGRU:cNombre  :=""
   oVTAGRUVSGRU:dDesde   :=dDesde
   oVTAGRUVSGRU:cServer  :=cServer
   oVTAGRUVSGRU:dHasta   :=dHasta
   oVTAGRUVSGRU:cWhere   :=cWhere
   oVTAGRUVSGRU:cWhere_  :=cWhere_
   oVTAGRUVSGRU:cWhereQry:=""
   oVTAGRUVSGRU:cSql     :=oDp:cSql
   oVTAGRUVSGRU:oWhere   :=TWHERE():New(oVTAGRUVSGRU)
   oVTAGRUVSGRU:cCodPar  :=cCodPar // Código del Parámetro
   oVTAGRUVSGRU:lWhen    :=.T.
   oVTAGRUVSGRU:cTextTit :="" // Texto del Titulo Heredado
   oVTAGRUVSGRU:oDb      :=oDp:oDb
   oVTAGRUVSGRU:cBrwCod  :="VTAGRUVSGRU"
   oVTAGRUVSGRU:lTmdi    :=.T.
   oVTAGRUVSGRU:aHead    :={}
   oVTAGRUVSGRU:lBarDef  :=.T. // Activar Modo Diseño.
   oVTAGRUVSGRU:lTiempoT :=.T. // Tiempo Transcurrido, Comparar Año 2022 Vs 2023 es asimetrico


   oVTAGRUVSGRU:lWhenPeriodo2:=.T.
   oVTAGRUVSGRU:lData        :=.F.


   oVTAGRUVSGRU:oPeriodo :=NIL
   oVTAGRUVSGRU:nPeriodo2:=nPeriodo
   oVTAGRUVSGRU:cPeriodo2:=aPeriodos[oVTAGRUVSGRU:nPeriodo2]
   oVTAGRUVSGRU:dDesde2  :=dDesde
   oVTAGRUVSGRU:dHasta2  :=dHasta

   oVTAGRUVSGRU:cTendencia :=cTendencia  // Cual
   oVTAGRUVSGRU:aFieldsText:={"Cantidad  ","Peso"    ,"Total "+oDp:cMoneda,"Total $","Frecuencia"}
   oVTAGRUVSGRU:aFields    :={"GRU_CANTID","GRU_PESO","GRU_TOTAL","GRU_MTODIV"      ,"GRU_FECHA "}
   oVTAGRUVSGRU:cFieldText :=oVTAGRUVSGRU:aFieldsText[1]
   oVTAGRUVSGRU:oField     :=NIL
 
   IF !Empty(cField)
      oVTAGRUVSGRU:cField     :=oVTAGRUVSGRU:aFields[1]
   ELSE
      oVTAGRUVSGRU:cField     :=cField
   ENDIF

   // ? oVTAGRUVSGRU:cField,"oVTAGRUVSGRU:cField"
   // Guarda los parámetros del Browse cuando cierra la ventana
   oVTAGRUVSGRU:bValid   :={|| EJECUTAR("BRWSAVEPAR",oVTAGRUVSGRU)}

   oVTAGRUVSGRU:lBtnRun     :=.F.
   oVTAGRUVSGRU:lBtnMenuBrw :=.F.
   oVTAGRUVSGRU:lBtnSave    :=.F.
   oVTAGRUVSGRU:lBtnCrystal :=.F.
   oVTAGRUVSGRU:lBtnRefresh :=.F.
   oVTAGRUVSGRU:lBtnHtml    :=.T.
   oVTAGRUVSGRU:lBtnExcel   :=.T.
   oVTAGRUVSGRU:lBtnPreview :=.T.
   oVTAGRUVSGRU:lBtnQuery   :=.F.
   oVTAGRUVSGRU:lBtnOptions :=.T.
   oVTAGRUVSGRU:lBtnPageDown:=.T.
   oVTAGRUVSGRU:lBtnPageUp  :=.T.
   oVTAGRUVSGRU:lBtnFilters :=.T.
   oVTAGRUVSGRU:lBtnFind    :=.T.
   oVTAGRUVSGRU:lBtnColor   :=.T.

   oVTAGRUVSGRU:nClrPane1:=16775408
   oVTAGRUVSGRU:nClrPane2:=16771797

   oVTAGRUVSGRU:nClrText :=0
   oVTAGRUVSGRU:nClrText1:=16711935
   oVTAGRUVSGRU:nClrText2:=0
   oVTAGRUVSGRU:nClrText3:=0

   oVTAGRUVSGRU:oBrw:=TXBrowse():New( IF(oVTAGRUVSGRU:lTmdi,oVTAGRUVSGRU:oWnd,oVTAGRUVSGRU:oDlg ))
   oVTAGRUVSGRU:oBrw:SetArray( aData, .F. )
   oVTAGRUVSGRU:oBrw:SetFont(oFont)

   oVTAGRUVSGRU:oBrw:lFooter     := .T.
   oVTAGRUVSGRU:oBrw:lHScroll    := .F.
   oVTAGRUVSGRU:oBrw:nHeaderLines:= 2
   oVTAGRUVSGRU:oBrw:nDataLines  := 1
   oVTAGRUVSGRU:oBrw:nFooterLines:= 1

   oVTAGRUVSGRU:aData            :=ACLONE(aData)

   AEVAL(oVTAGRUVSGRU:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  // Campo: GRU_CODIGO
  oCol:=oVTAGRUVSGRU:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAGRUVSGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  // Campo: GRU_DESCRI
  oCol:=oVTAGRUVSGRU:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAGRUVSGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  // Campo: VALDESDE
  oCol:=oVTAGRUVSGRU:oBrw:aCols[3]
  oCol:cHeader      :='Valor'+CRLF+'Anterior'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAGRUVSGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAGRUVSGRU:oBrw:aArrayData[oVTAGRUVSGRU:oBrw:nArrayAt,3],;
                              oCol  := oVTAGRUVSGRU:oBrw:aCols[3],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[3],oCol:cEditPicture)

  // Campo: VALHASTA
  oCol:=oVTAGRUVSGRU:oBrw:aCols[4]
  oCol:cHeader      :='Valor'+CRLF+'Actual'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAGRUVSGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAGRUVSGRU:oBrw:aArrayData[oVTAGRUVSGRU:oBrw:nArrayAt,4],;
                              oCol  := oVTAGRUVSGRU:oBrw:aCols[4],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[4],oCol:cEditPicture)


  // Campo: VALDIF
  oCol:=oVTAGRUVSGRU:oBrw:aCols[5]
  oCol:cHeader      :='Valor'+CRLF+'Diferente'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAGRUVSGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oVTAGRUVSGRU:oBrw:aArrayData[oVTAGRUVSGRU:oBrw:nArrayAt,5],;
                              oCol  := oVTAGRUVSGRU:oBrw:aCols[5],;
                              FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)

// Campo: VALDIF
  oCol:=oVTAGRUVSGRU:oBrw:aCols[6]
  oCol:cHeader      :='%'+CRLF+'Prop'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oVTAGRUVSGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol,aLine|aLine:=oVTAGRUVSGRU:oBrw:aArrayData[oVTAGRUVSGRU:oBrw:nArrayAt],;
                                     nMonto:= aLine[6],;
                                     oCol  := oVTAGRUVSGRU:oBrw:aCols[6],;
                                     IF( aLine[3]=0,"Debuta",FDP(nMonto,oCol:cEditPicture))}
//   oCol:cFooter      :=FDP(aTotal[5],oCol:cEditPicture)

   oVTAGRUVSGRU:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oVTAGRUVSGRU:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oVTAGRUVSGRU:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oVTAGRUVSGRU:nClrText,;
                                                 nClrText:=IF(aLine[3]=0,oVTAGRUVSGRU:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oVTAGRUVSGRU:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oVTAGRUVSGRU:nClrPane1, oVTAGRUVSGRU:nClrPane2 ) } }

//   oVTAGRUVSGRU:oBrw:bClrHeader            := {|| {0,14671839 }}
//   oVTAGRUVSGRU:oBrw:bClrFooter            := {|| {0,14671839 }}

   oVTAGRUVSGRU:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oVTAGRUVSGRU:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oVTAGRUVSGRU:oBrw:bLDblClick:={|oBrw|oVTAGRUVSGRU:RUNCLICK() }

   oVTAGRUVSGRU:oBrw:bChange:={||oVTAGRUVSGRU:BRWCHANGE()}
   oVTAGRUVSGRU:oBrw:CreateFromCode()

   oVTAGRUVSGRU:oWnd:oClient := oVTAGRUVSGRU:oBrw

   oVTAGRUVSGRU:Activate({||oVTAGRUVSGRU:ViewDatBar()})

   oVTAGRUVSGRU:lWhenPeriodo2:=.T.
   oVTAGRUVSGRU:oBtnRun2:ForWhen(.T.)

   oVTAGRUVSGRU:BRWRESTOREPAR()

   SysRefresh(.T.)
   oVTAGRUVSGRU:SETPERIODO2()
  
   CursorWait()

   oVTAGRUVSGRU:LEEFECHAS(.T.)

   CursorArrow()


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,oFontT
   LOCAL oDlg:=IF(oVTAGRUVSGRU:lTmdi,oVTAGRUVSGRU:oWnd,oVTAGRUVSGRU:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oVTAGRUVSGRU:oBrw:nWidth()

   oVTAGRUVSGRU:oBrw:GoBottom(.T.)
   oVTAGRUVSGRU:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRVTAGRUVSGRU.EDT")
//     oVTAGRUVSGRU:oBrw:Move(44,0,536+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6+60 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oVTAGRUVSGRU:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oVTAGRUVSGRU:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oVTAGRUVSGRU:oBrw:oLbx  :=oVTAGRUVSGRU    // MDI:GOTFOCUS()

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          TOP PROMPT "Ejecutar";
          ACTION (oVTAGRUVSGRU:lData:=.T.,;
                  oVTAGRUVSGRU:LEEFECHAS(.T.))

   oBtn:cToolTip:="Ejecutar Consulta"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\GRUPOS.BMP";
          TOP PROMPT "Grupo";
          ACTION EJECUTAR("DPGRU",0,oVTAGRUVSGRU:oBrw:aArrayData[oVTAGRUVSGRU:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Grupo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          TOP PROMPT "Grupo";
          ACTION EJECUTAR("DPGRUCON",NIL,oVTAGRUVSGRU:oBrw:aArrayData[oVTAGRUVSGRU:oBrw:nArrayAt,1])

    oBtn:cToolTip:="Consultar"



/*
   IF Empty(oVTAGRUVSGRU:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","VTAGRUVSGRU")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","VTAGRUVSGRU"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oVTAGRUVSGRU:oBrw,"VTAGRUVSGRU",oVTAGRUVSGRU:cSql,oVTAGRUVSGRU:nPeriodo,oVTAGRUVSGRU:dDesde,oVTAGRUVSGRU:dHasta,oVTAGRUVSGRU)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oVTAGRUVSGRU:oBtnRun:=oBtn



       oVTAGRUVSGRU:oBrw:bLDblClick:={||EVAL(oVTAGRUVSGRU:oBtnRun:bAction) }


   ENDIF




IF oVTAGRUVSGRU:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oVTAGRUVSGRU");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oVTAGRUVSGRU:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oVTAGRUVSGRU:lBtnColor

     oVTAGRUVSGRU:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU,oVTAGRUVSGRU:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oVTAGRUVSGRU,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oVTAGRUVSGRU,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oVTAGRUVSGRU:oBtnColor:=oBtn

ENDIF

IF oVTAGRUVSGRU:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Guardar";
             ACTION EJECUTAR("DPBRWSAVE",oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU:oFrm)

ENDIF

IF oVTAGRUVSGRU:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oVTAGRUVSGRU),;
                  EJECUTAR("DPBRWMENURUN",oVTAGRUVSGRU,oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU:cBrwCod,oVTAGRUVSGRU:cTitle,oVTAGRUVSGRU:aHead));
          WHEN !Empty(oVTAGRUVSGRU:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oVTAGRUVSGRU:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oVTAGRUVSGRU:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oVTAGRUVSGRU:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU);
          ACTION EJECUTAR("BRWSETFILTER",oVTAGRUVSGRU:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oVTAGRUVSGRU:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oVTAGRUVSGRU:oBrw);
          WHEN LEN(oVTAGRUVSGRU:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oVTAGRUVSGRU:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oVTAGRUVSGRU:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oVTAGRUVSGRU:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oVTAGRUVSGRU)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oVTAGRUVSGRU:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU:cTitle,oVTAGRUVSGRU:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oVTAGRUVSGRU:oBtnXls:=oBtn

ENDIF

IF oVTAGRUVSGRU:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oVTAGRUVSGRU:HTMLHEAD(),EJECUTAR("BRWTOHTML",oVTAGRUVSGRU:oBrw,NIL,oVTAGRUVSGRU:cTitle,oVTAGRUVSGRU:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oVTAGRUVSGRU:oBtnHtml:=oBtn

ENDIF


IF oVTAGRUVSGRU:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oVTAGRUVSGRU:oBrw))

   oBtn:cToolTip:="Previsualización"

   oVTAGRUVSGRU:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRVTAGRUVSGRU")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oVTAGRUVSGRU:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oVTAGRUVSGRU:oBtnPrint:=oBtn

   ENDIF

IF oVTAGRUVSGRU:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oVTAGRUVSGRU:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oVTAGRUVSGRU:oBrw:GoTop(),oVTAGRUVSGRU:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oVTAGRUVSGRU:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oVTAGRUVSGRU:oBrw:PageDown(),oVTAGRUVSGRU:oBrw:Setfocus())

  ENDIF

  IF  oVTAGRUVSGRU:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oVTAGRUVSGRU:oBrw:PageUp(),oVTAGRUVSGRU:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oVTAGRUVSGRU:oBrw:GoBottom(),oVTAGRUVSGRU:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oVTAGRUVSGRU:Close()

  oVTAGRUVSGRU:oBrw:SetColor(0,oVTAGRUVSGRU:nClrPane1)

  IF oDp:lBtnText
     oVTAGRUVSGRU:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oVTAGRUVSGRU:SETBTNBAR(40,40,oBar)
  ENDIF

  EVAL(oVTAGRUVSGRU:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oVTAGRUVSGRU:oBar:=oBar

    nCol:=176
  //nLin:=<NLIN> // 08

  // Controles se Inician luego del Ultimo Boton
  nCol:=32+40+10
  nLin:=70

  DEFINE FONT oFontT  NAME "Tahoma"   SIZE 0, -11 BOLD


  @ nLin   ,10 SAY "Actual" SIZE 60,20;
                    PIXEL;
                    OF oBar;
                    FONT oFontT COLOR 0,oDp:nGris RIGHT

  @ nLin+28,10 SAY "Anterior" SIZE 60,20;
                    PIXEL;
                    OF oBar;
                    FONT oFontT COLOR 0,oDp:nGris RIGHT

  //  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })
  //
  // Campo : Periodo
  //

  @ nLin, nCol COMBOBOX oVTAGRUVSGRU:oPeriodo  VAR oVTAGRUVSGRU:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFontT;
                ON CHANGE (oVTAGRUVSGRU:LEEFECHAS(.F.),oVTAGRUVSGRU:SETPERIODO2());
                WHEN oVTAGRUVSGRU:lWhen


  ComboIni(oVTAGRUVSGRU:oPeriodo )

  @ nLin, nCol+103 BUTTON oVTAGRUVSGRU:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oVTAGRUVSGRU:oPeriodo:nAt,oVTAGRUVSGRU:oDesde,oVTAGRUVSGRU:oHasta,-1),;
                         oVTAGRUVSGRU:SETPERIODO2(),;
                         EVAL(oVTAGRUVSGRU:oBtnRun:bAction));
                WHEN oVTAGRUVSGRU:lWhen


  @ nLin, nCol+130 BUTTON oVTAGRUVSGRU:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oVTAGRUVSGRU:oPeriodo:nAt,oVTAGRUVSGRU:oDesde,oVTAGRUVSGRU:oHasta,+1),;
                         EVAL(oVTAGRUVSGRU:oBtnRun:bAction));
                WHEN oVTAGRUVSGRU:lWhen


  @ nLin, nCol+160 BMPGET oVTAGRUVSGRU:oDesde  VAR oVTAGRUVSGRU:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oVTAGRUVSGRU:oDesde ,oVTAGRUVSGRU:dDesde);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oVTAGRUVSGRU:oPeriodo:nAt=LEN(oVTAGRUVSGRU:oPeriodo:aItems) .AND. oVTAGRUVSGRU:lWhen ;
                FONT oFont

   oVTAGRUVSGRU:oDesde:cToolTip:="F6: Calendario"

  @ nLin, nCol+252 BMPGET oVTAGRUVSGRU:oHasta  VAR oVTAGRUVSGRU:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oVTAGRUVSGRU:oHasta,oVTAGRUVSGRU:dHasta);
                SIZE 76-2,24;
                WHEN oVTAGRUVSGRU:oPeriodo:nAt=LEN(oVTAGRUVSGRU:oPeriodo:aItems) .AND. oVTAGRUVSGRU:lWhen ;
                OF oBar;
                FONT oFont

   oVTAGRUVSGRU:oHasta:cToolTip:="F6: Calendario"

   @ nLin, nCol+345 BUTTON oVTAGRUVSGRU:oBtnRun PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oVTAGRUVSGRU:oPeriodo:nAt=LEN(oVTAGRUVSGRU:oPeriodo:aItems);
               ACTION oVTAGRUVSGRU:HACERWHERE(oVTAGRUVSGRU:dDesde,oVTAGRUVSGRU:dHasta,oVTAGRUVSGRU:cWhere,.T.);
               WHEN oVTAGRUVSGRU:lWhen


  //
  // Campo : Periodo2
  //

  @ nLin+28, nCol COMBOBOX oVTAGRUVSGRU:oPeriodo2  VAR oVTAGRUVSGRU:cPeriodo2 ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFontT;
                ON CHANGE oVTAGRUVSGRU:LEEFECHAS(.F.);
                WHEN oVTAGRUVSGRU:lWhen


  ComboIni(oVTAGRUVSGRU:oPeriodo2 )

  @ nLin+28, nCol+103 BUTTON oVTAGRUVSGRU:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFontT;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oVTAGRUVSGRU:oPeriodo2:nAt,oVTAGRUVSGRU:oDesde2,oVTAGRUVSGRU:oHasta2,-1),;
                         EVAL(oVTAGRUVSGRU:oBtnRun:bAction));
                WHEN oVTAGRUVSGRU:lWhen


  @ nLin+28, nCol+130 BUTTON oVTAGRUVSGRU:oBtn2 PROMPT " > " SIZE 27,24;
                 FONT oFontT;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oVTAGRUVSGRU:oPeriodo2:nAt,oVTAGRUVSGRU:oDesde2,oVTAGRUVSGRU:oHasta2,+1),;
                         EVAL(oVTAGRUVSGRU:oBtnRun:bAction));
                WHEN oVTAGRUVSGRU:lWhen


  @ nLin+28, nCol+160 BMPGET oVTAGRUVSGRU:oDesde2  VAR oVTAGRUVSGRU:dDesde2;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oVTAGRUVSGRU:oDesde2 ,oVTAGRUVSGRU:dDesde2);
                SIZE 76-2,24;
                OF   oBar;
                WHEN oVTAGRUVSGRU:oPeriodo2:nAt=LEN(oVTAGRUVSGRU:oPeriodo2:aItems) .AND. oVTAGRUVSGRU:lWhen ;
                FONT oFont

   oVTAGRUVSGRU:oDesde2:cToolTip:="F6: Calendario"

  @ nLin+28, nCol+252 BMPGET oVTAGRUVSGRU:oHasta2  VAR oVTAGRUVSGRU:dHasta2;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oVTAGRUVSGRU:oHasta2,oVTAGRUVSGRU:dHasta2);
                SIZE 76-2,24;
                WHEN oVTAGRUVSGRU:oPeriodo2:nAt=LEN(oVTAGRUVSGRU:oPeriodo2:aItems) .AND. oVTAGRUVSGRU:lWhen ;
                OF oBar;
                FONT oFont

  oVTAGRUVSGRU:oHasta2:cToolTip:="F6: Calendario"

  oVTAGRUVSGRU:lWhenPeriodo2:=.T.

  @ nLin+28, nCol+345 BUTTON oVTAGRUVSGRU:oBtnRun2 PROMPT " >< " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oVTAGRUVSGRU:lWhenPeriodo2;
               ACTION oVTAGRUVSGRU:SELPERIODO2();
              
  BMPGETBTN(oBar,oFont,13)


  // Campo : Tendencia
  //

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD


  @ nLin, nCol+380 SAY "Tendencia" SIZE 65,20;
                   PIXEL;
                   OF oBar;
                   FONT oFontT COLOR 0,oDp:nGris RIGHT

  @ nLin+28, nCol+380 SAY "Campo" SIZE 65,20;
                      PIXEL;
                      OF oBar;
                      FONT oFontT COLOR 0,oDp:nGris RIGHT

  @ nLin, nCol+460 COMBOBOX oVTAGRUVSGRU:oTendencia  VAR oVTAGRUVSGRU:cTendencia ITEMS {" > Incrementó"," < Disminuyó"," 1 Debutó"," 0 Retiró"," = Igualó"};
                SIZE 100+10,200;
                PIXEL;
                OF oBar;
                FONT oFontT;
                ON CHANGE oVTAGRUVSGRU:LEEFECHAS(.F.);
                WHEN oVTAGRUVSGRU:lWhen

  ComboIni(oVTAGRUVSGRU:oTendencia)

  @ nLin+28, nCol+460 COMBOBOX oVTAGRUVSGRU:oFieldText VAR oVTAGRUVSGRU:cFieldText ITEMS oVTAGRUVSGRU:aFieldsText;
                SIZE 100,200+10;
                PIXEL;
                OF oBar;
                FONT oFontT;
                ON CHANGE ( oVTAGRUVSGRU:cField:=oVTAGRUVSGRU:aFields[oVTAGRUVSGRU:oFieldText:nAt],;
                            oVTAGRUVSGRU:LEEFECHAS(.F.));
                WHEN oVTAGRUVSGRU:lWhen

  ComboIni(oVTAGRUVSGRU:oFieldText)

  oVTAGRUVSGRU:lTiempoT:=.T.

  @ nLin, nCol+460+120 CHECKBOX oVTAGRUVSGRU:lTiempoT PROMPT ANSITOOEM("Tiempo Transcurrido");
          ON CHANGE .T. OF oBar PIXEL FONT oFontT SIZE 135,24 

//SIZE 100,100

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRVTAGRUVSGRU",cWhere)
  oRep:cSql  :=oVTAGRUVSGRU:cSql
  oRep:cTitle:=oVTAGRUVSGRU:cTitle

RETURN .T.

FUNCTION LEEFECHAS(lData)
  LOCAL nPeriodo:=oVTAGRUVSGRU:oPeriodo:nAt,cWhere

  DEFAULT lData:=.T.

  oVTAGRUVSGRU:nPeriodo:=nPeriodo
  oVTAGRUVSGRU:lData   :=lData

  IF oVTAGRUVSGRU:oPeriodo:nAt=LEN(oVTAGRUVSGRU:oPeriodo:aItems)

     oVTAGRUVSGRU:oDesde:ForWhen(.T.)
     oVTAGRUVSGRU:oHasta:ForWhen(.T.)
     oVTAGRUVSGRU:oBtn  :ForWhen(.T.)

     DPFOCUS(oVTAGRUVSGRU:oDesde)

  ELSE

/*
     oVTAGRUVSGRU:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oVTAGRUVSGRU:oDesde:VarPut(oVTAGRUVSGRU:aFechas[1] , .T. )
     oVTAGRUVSGRU:oHasta:VarPut(oVTAGRUVSGRU:aFechas[2] , .T. )

     oVTAGRUVSGRU:dDesde:=oVTAGRUVSGRU:aFechas[1]
     oVTAGRUVSGRU:dHasta:=oVTAGRUVSGRU:aFechas[2]

? oVTAGRUVSGRU:dDesde,oVTAGRUVSGRU:dHasta

//     oVTAGRUVSGRU:SETPERIODO2()
*/
     IF lData

       cWhere:=oVTAGRUVSGRU:HACERWHERE(oVTAGRUVSGRU:dDesde,oVTAGRUVSGRU:dHasta,oVTAGRUVSGRU:cWhere,.T.)
       oVTAGRUVSGRU:LEERDATA(cWhere,oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU:cServer,oVTAGRUVSGRU)

     ENDIF

  ENDIF

  oVTAGRUVSGRU:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "VIEW_DPGRUPO_VTA.GRU_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('T1.GRU_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('T1_VTA.GRU_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oVTAGRUVSGRU:cWhereQry)
       cWhere:=cWhere + oVTAGRUVSGRU:cWhereQry
     ENDIF

     oVTAGRUVSGRU:SETPERIODO2()

     oVTAGRUVSGRU:LEERDATA(cWhere,oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU:cServer,oVTAGRUVSGRU)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oFrmMdi,cCodSuc,dDesde,dHasta,cTendencia,cField,lData,lTiempoT)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={},oCol
   LOCAL oDb
   LOCAL nAt,nRowSel
   LOCAL dDesde2:=NIL,dHasta2:=NIL,nDias:=0

   DEFAULT cWhere  :="",;
           cCodSuc :=oDp:cSucursal,;
           lData   :=.F.,;
           lTiempoT:=.T.

// ? oFrmMdi,ValType(oFrmMdi),lData,ValType(lData)

   IF TYPE("oFrmMdi")="O"

      cCodSuc   :=oFrmMdi:cCodSuc
      dDesde    :=oFrmMdi:dDesde
      dHasta    :=oFrmMdi:dHasta

      dDesde2   :=oFrmMdi:dDesde2
      dHasta2   :=oFrmMdi:dHasta2

      cTendencia:=oFrmMdi:cTendencia
      cField    :=oFrmMdi:cField
      lData     :=oFrmMdi:lData 
      lTiempoT  :=oFrmMdi:lTiempoT

   ENDIF

   CursorWait()

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cWhere:=IIF(Empty(cWhere),"",ALLTRIM(cWhere))

   IF !Empty(cWhere) .AND. LEFT(cWhere,5)="WHERE"
      cWhere:=SUBS(cWhere,6,LEN(cWhere))
   ENDIF

   cSql:=" SELECT  "+;
          " GRU_CODIGO, "+;
          " GRU_DESCRI,"+;
          " SUM(GRU_CANTID) AS VALDESDE, "+;
          " 0 AS VALHASTA,"+;
          " 0 AS VALDIF,0 AS UNO, 0 AS DOS"+;
          " FROM VIEW_DPGRUPO_VTA AS T1 "+;
          " GROUP BY GRU_CODIGO"+;
""

/*
   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF
*/
   IF !Empty(cWhere)
      cSql:=EJECUTAR("SQLINSERTWHERE",cSql,cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   oDp:lExcluye:=.F.


   IF lData

      aData:=EJECUTAR("GRUVTAVSGRUVTA",cWhere,cCodSuc,dDesde,dHasta,dDesde2,dHasta2,cTendencia,"VIEW_DPGRUPO_VTA","GRU_CODIGO","GRU_DESCRI",cField,"GRU_FECHA")

      DPWRITE("TEMP\BRVTAGRUVSGRU.SQL",oDp:cSql)

   ELSE

      aData:={}
      AADD(aData,{"","",0,0,0,0})

   ENDIF

   oDp:cWhere:=cWhere

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
   ENDIF
  

   IF ValType(oBrw)="O"

      oFrmMdi:cSql   :=cSql
      oFrmMdi:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      oCol:=oFrmMdi:oBrw:aCols[6]
      oCol:cFooter      :=FDP(RATA(aTotal[4],aTotal[3]),oCol:cEditPicture)


      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oFrmMdi:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oFrmMdi:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRVTAGRUVSGRU.MEM",V_nPeriodo:=oVTAGRUVSGRU:nPeriodo
  LOCAL V_dDesde:=oVTAGRUVSGRU:dDesde
  LOCAL V_dHasta:=oVTAGRUVSGRU:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oVTAGRUVSGRU)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oVTAGRUVSGRU")="O" .AND. oVTAGRUVSGRU:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oVTAGRUVSGRU:cWhere_),oVTAGRUVSGRU:cWhere_,oVTAGRUVSGRU:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oVTAGRUVSGRU:LEERDATA(oVTAGRUVSGRU:cWhere_,oVTAGRUVSGRU:oBrw,oVTAGRUVSGRU:cServer,oVTAGRUVSGRU)
      oVTAGRUVSGRU:oWnd:Show()
      oVTAGRUVSGRU:oWnd:Restore()

    ENDIF

RETURN NIL

FUNCTION BTNRUN()
    ? "PERSONALIZA FUNCTION DE BTNRUN"
RETURN .T.

FUNCTION BTNMENU(nOption,cOption)

   ? nOption,cOption,"PESONALIZA LAS SUB-OPCIONES"

   IF nOption=1
   ENDIF

   IF nOption=2
   ENDIF

   IF nOption=3
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oVTAGRUVSGRU:aHead:=EJECUTAR("HTMLHEAD",oVTAGRUVSGRU)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oVTAGRUVSGRU)
RETURN .T.

FUNCTION SETPERIODO2()
  LOCAL nDias:=0

  oVTAGRUVSGRU:oPeriodo2:Select(oVTAGRUVSGRU:oPeriodo:nAt)

  oVTAGRUVSGRU:oDesde2:VarPut(oVTAGRUVSGRU:dDesde,.T.)
  oVTAGRUVSGRU:oHasta2:VarPut(oVTAGRUVSGRU:dHasta2,.T.)

  EJECUTAR("PERIODOMAS",oVTAGRUVSGRU:oPeriodo:nAt,oVTAGRUVSGRU:oDesde2,oVTAGRUVSGRU:oHasta2,-1)

  oVTAGRUVSGRU:SETTIEMPO()


//  oVTAGRUVSGRU:LEEFECHAS(.F.)

RETURN .T.

FUNCTION SETTIEMPO()
  LOCAL nDias

  IF oVTAGRUVSGRU:lTiempoT

     nDias:=oVTAGRUVSGRU:dHasta-oDp:dFecha

     IF oVTAGRUVSGRU:dHasta>=oDp:dFecha

        oVTAGRUVSGRU:dHasta :=oDp:dFecha

        IF oVTAGRUVSGRU:oPeriodo:nAt=9 // Anual
           oVTAGRUVSGRU:dHasta2:=FCHANUAL(oVTAGRUVSGRU:dHasta,oVTAGRUVSGRU:dHasta2)
        ENDIF

        oVTAGRUVSGRU:oHasta:VarPut(oVTAGRUVSGRU:dHasta,.T.)
        oVTAGRUVSGRU:oHasta2:VarPut(oVTAGRUVSGRU:dHasta2,.T.)

     ENDIF

  ENDIF

RETURN .T.

FUNCTION SELPERIODO2()
   LOCAL dFechaSis:=oVTAGRUVSGRU:dDesde,cPeriodo:=oVTAGRUVSGRU:cPeriodo,lSelPer:=.T.

   // oDp:lDpXbase:=.T.

   EJECUTAR("SEMANARIO",dFechaSis,cPeriodo,lSelPer,oVTAGRUVSGRU:oBtnRun2)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/


// EOF

