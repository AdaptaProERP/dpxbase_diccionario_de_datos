// Programa   : BRCNDPROPIET
// Fecha/Hora : 03/02/2024 01:14:19
// Propósito  : "Propietarios"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,cCenCos,lView)
   LOCAL aData,aFechas,cFileMem:="USER\BRCNDPROPIET.MEM",V_nPeriodo:=1,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.
   LOCAL aFields  :={}

   oDp:cRunServer:=NIL

   IF Type("oCNDPROPIET")="O" .AND. oCNDPROPIET:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oCNDPROPIET,GetScript())
   ENDIF

   DEFAULT cCenCos:=oDp:cCenCos,;
           lView  :=.F.

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF


   cTitle:="Propietarios" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

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

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer,NIL,cCenCos)

   aFields:=ACLONE(oDp:aFields) // genera los campos Virtuales

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oCNDPROPIET

RETURN .T.

FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oCNDPROPIET","BRCNDPROPIET.EDT")
// oCNDPROPIET:CreateWindow(0,0,100,550)
   oCNDPROPIET:Windows(0,0,aCoors[3]-160,MIN(1034,aCoors[4]-10),.T.) // Maximizado

   oCNDPROPIET:cCodSuc  :=cCodSuc
   oCNDPROPIET:lMsgBar  :=.F.
   oCNDPROPIET:cPeriodo :=aPeriodos[nPeriodo]
   oCNDPROPIET:cCodSuc  :=cCodSuc
   oCNDPROPIET:nPeriodo :=nPeriodo
   oCNDPROPIET:cNombre  :=""
   oCNDPROPIET:dDesde   :=dDesde
   oCNDPROPIET:cServer  :=cServer
   oCNDPROPIET:dHasta   :=dHasta
   oCNDPROPIET:cWhere   :=cWhere
   oCNDPROPIET:cWhere_  :=cWhere_
   oCNDPROPIET:cWhereQry:=""
   oCNDPROPIET:cSql     :=oDp:cSql
   oCNDPROPIET:oWhere   :=TWHERE():New(oCNDPROPIET)
   oCNDPROPIET:cCodPar  :=cCodPar // Código del Parámetro
   oCNDPROPIET:lWhen    :=.T.
   oCNDPROPIET:cTextTit :="" // Texto del Titulo Heredado
   oCNDPROPIET:oDb      :=oDp:oDb
   oCNDPROPIET:cBrwCod  :="CNDPROPIET"
   oCNDPROPIET:lTmdi    :=.T.
   oCNDPROPIET:aHead     :={}
   oCNDPROPIET:lBarDef   :=.T. // Activar Modo Diseño.
   oCNDPROPIET:aFields   :=ACLONE(aFields)
   oCNDPROPIET:aLineCopy :={}
   oCNDPROPIET:cCenCos   :=cCenCos
   oCNDPROPIET:lNewRecord:=(LEN(aData)=1 .AND. Empty(aData[1,1]))
   oCNDPROPIET:lSaved    :=.F.

   AEVAL(aFields,{|a,n| oCNDPROPIET:SET("COL_"+a[1],n)}) // Campos Virtuales en el Browse

   // Guarda los parámetros del Browse cuando cierra la ventana
   oCNDPROPIET:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCNDPROPIET)}

   oCNDPROPIET:lBtnNew     :=.T.
   oCNDPROPIET:lBtnRun     :=.F.
   oCNDPROPIET:lBtnMenuBrw :=.F.
   oCNDPROPIET:lBtnSave    :=.F.
   oCNDPROPIET:lBtnCrystal :=.F.
   oCNDPROPIET:lBtnRefresh :=.F.
   oCNDPROPIET:lBtnHtml    :=.T.
   oCNDPROPIET:lBtnExcel   :=.T.
   oCNDPROPIET:lBtnPreview :=.T.
   oCNDPROPIET:lBtnQuery   :=.F.
   oCNDPROPIET:lBtnOptions :=.T.
   oCNDPROPIET:lBtnPageDown:=.T.
   oCNDPROPIET:lBtnPageUp  :=.T.
   oCNDPROPIET:lBtnFilters :=.T.
   oCNDPROPIET:lBtnFind    :=.T.
   oCNDPROPIET:lBtnColor   :=.T.

   oCNDPROPIET:nClrPane1:=16775408
   oCNDPROPIET:nClrPane2:=16771797

   oCNDPROPIET:nClrText :=0
   oCNDPROPIET:nClrText1:=0
   oCNDPROPIET:nClrText2:=0
   oCNDPROPIET:nClrText3:=0

   oCNDPROPIET:oBrw:=TXBrowse():New( IF(oCNDPROPIET:lTmdi,oCNDPROPIET:oWnd,oCNDPROPIET:oDlg ))
   oCNDPROPIET:oBrw:SetArray( aData, .F. )
   oCNDPROPIET:oBrw:SetFont(oFont)
   oCNDPROPIET:oBrw:oFontBrw:=oFont

   oCNDPROPIET:oBrw:lFooter     := .T.
   oCNDPROPIET:oBrw:lHScroll    := .F.
   oCNDPROPIET:oBrw:nHeaderLines:= 2
   oCNDPROPIET:oBrw:nDataLines  := 1
   oCNDPROPIET:oBrw:nFooterLines:= 1

   oCNDPROPIET:aData            :=ACLONE(aData)

   AEVAL(oCNDPROPIET:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  

  // Campo: CLI_RIF
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CLI_RIF]
  oCol:cHeader      :='RIF'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 80
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:VALRIF(oCol,uValue,oCNDPROPIET:COL_CLI_RIF,nKey)}
  oCol:lButton      :=.F.


  // Campo: CLI_NOMBRE
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CLI_NOMBRE]
  oCol:cHeader      :='Nombre del Propietario'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 280
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:PUTFIELDVALUE(oCol,uValue,oCNDPROPIET:COL_CLI_NOMBRE,nKey,NIL,.T.)}
  oCol:lButton      :=.F.


  // Campo: CLI_TEL1
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CLI_TEL1]
  oCol:cHeader      :='Teléfono'+CRLF+'Ws'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:PUTFIELDVALUE(oCol,uValue,oCNDPROPIET:COL_CLI_TEL1,nKey,NIL,.T.)}

  // Campo: CLI_TEL2
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CLI_TEL2]
  oCol:cHeader      :='Teléfono'+CRLF+'2'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:PUTFIELDVALUE(oCol,uValue,oCNDPROPIET:COL_CLI_TEL2,nKey,NIL,.T.)}


  // Campo: CLI_EMAIL
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CLI_EMAIL]
  oCol:cHeader      :='Correo'+CRLF+'Electrónico'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 190
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:PUTFIELDVALUE(oCol,uValue,oCNDPROPIET:COL_CLI_EMAIL,nKey,NIL,.T.)}

  // Campo: CRC_ID
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CRC_ID]
  oCol:cHeader      :='ID'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:PUTFIELDVALUE(oCol,uValue,oCNDPROPIET:COL_CRC_ID,nKey,NIL,.T.)}


  // Campo: CRC_USO
  oCol:=oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CRC_USO]
  oCol:cHeader      :='%'+CRLF+'Alícuota'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oCNDPROPIET:oBrw:aArrayData ) } 
  oCol:nWidth       := 144
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='999.9999'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oCNDPROPIET:oBrw:aArrayData[oCNDPROPIET:oBrw:nArrayAt,oCNDPROPIET:COL_CRC_USO],;
                              oCol  := oCNDPROPIET:oBrw:aCols[oCNDPROPIET:COL_CRC_USO],;
                              TRANSF(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[oCNDPROPIET:COL_CRC_USO],oCol:cEditPicture)
  oCol:nEditType    :=IIF( lView, 0, 1)
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oCNDPROPIET:PUTFIELDVALUE(oCol,uValue,oCNDPROPIET:COL_CRC_USO,nKey,NIL,.T.,.T.,.T.)}

  oCNDPROPIET:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oCNDPROPIET:oBrw:bClrStd  := {|oBrw,nClrText,aLine|oBrw:=oCNDPROPIET:oBrw,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                                 nClrText:=oCNDPROPIET:nClrText,;
                                                 nClrText:=IF(.F.,oCNDPROPIET:nClrText1,nClrText),;
                                                 nClrText:=IF(.F.,oCNDPROPIET:nClrText2,nClrText),;
                                                 {nClrText,iif( oBrw:nArrayAt%2=0, oCNDPROPIET:nClrPane1, oCNDPROPIET:nClrPane2 ) } }

   oCNDPROPIET:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oCNDPROPIET:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oCNDPROPIET:oBrw:bLDblClick:={|oBrw|oCNDPROPIET:RUNCLICK() }

   oCNDPROPIET:oBrw:bChange:={||oCNDPROPIET:BRWCHANGE()}
   oCNDPROPIET:oBrw:CreateFromCode()

   oCNDPROPIET:oWnd:oClient := oCNDPROPIET:oBrw

   oCNDPROPIET:Activate({||oCNDPROPIET:ViewDatBar()})

   oCNDPROPIET:BRWRESTOREPAR()

//   IF !EMPTY(ATAIL(oCNDPROPIET:oBrw:aArrayData)[1])
//      oCNDPROPIET:BRWADDNEWLINE()
//   ENDIF

   DPFOCUS(oCNDPROPIET:oBrw)

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oCNDPROPIET:lTmdi,oCNDPROPIET:oWnd,oCNDPROPIET:oDlg)
   LOCAL nLin:=2,nCol:=0
   LOCAL nWidth:=oCNDPROPIET:oBrw:nWidth()

   oCNDPROPIET:oBrw:GoBottom(.T.)
   oCNDPROPIET:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRCNDPROPIET.EDT")
//     oCNDPROPIET:oBrw:Move(44,0,1034+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND

   IF oDp:lBtnText
     DEFINE BUTTONBAR oBar SIZE oDp:nBtnWidth,oDp:nBarnHeight+6 OF oDlg 3D CURSOR oCursor
   ELSE
     DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   ENDIF

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   oCNDPROPIET:oFontBtn   :=oFont     // MDI:GOTFOCUS()
   oCNDPROPIET:nClrPaneBar:=oDp:nGris // MDI:GOTFOCUS()
   oCNDPROPIET:oBrw:oLbx  :=oCNDPROPIET    // MDI:GOTFOCUS()




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oCNDPROPIET:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            TOP PROMPT "Consulta";
            ACTION EJECUTAR("BRWRUNLINK",oCNDPROPIET:oBrw,oCNDPROPIET:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   IF oCNDPROPIET:lBtnNew 

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XNEW.BMP",NIL,"BITMAPS\XNEWG.BMP";
             TOP PROMPT "Incluir";
             WHEN ISTABINC("DPCLIENTES");
             ACTION oCNDPROPIET:BRWADDNEWLINE()

      oBtn:cToolTip:="Incluir"
 
   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP",NIL,"BITMAPS\XDELETEG.BMP";
          WHEN ISTABELI("DPCLIENTES");
          TOP PROMPT "Eliminar";
          ACTION oCNDPROPIET:BRWDELETE()

  oBtn:cToolTip:="Eliminar"
 

/*
   IF Empty(oCNDPROPIET:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","CNDPROPIET")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","CNDPROPIET"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       TOP PROMPT "Detalles";
       ACTION EJECUTAR("BRWRUNBRWLINK",oCNDPROPIET:oBrw,"CNDPROPIET",oCNDPROPIET:cSql,oCNDPROPIET:nPeriodo,oCNDPROPIET:dDesde,oCNDPROPIET:dHasta,oCNDPROPIET)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oCNDPROPIET:oBtnRun:=oBtn



       oCNDPROPIET:oBrw:bLDblClick:={||EVAL(oCNDPROPIET:oBtnRun:bAction) }


   ENDIF




IF oCNDPROPIET:lBtnRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            MENU EJECUTAR("BRBTNMENU",{"Opcion 1",;
                                       "Opcion 2",;
                                       "Opcion 3"},;
                                       "oCNDPROPIET");
            FILENAME "BITMAPS\RUN.BMP";
            TOP PROMPT "Menú";
            ACTION oCNDPROPIET:BTNRUN()

      oBtn:cToolTip:="Opciones de Ejecucion"

ENDIF

IF oCNDPROPIET:lBtnColor

     oCNDPROPIET:oBtnColor:=NIL

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\COLORS.BMP";
            TOP PROMPT "Color";
            MENU EJECUTAR("BRBTNMENUCOLOR",oCNDPROPIET:oBrw,oCNDPROPIET,oCNDPROPIET:oBtnColor,{||EJECUTAR("BRWCAMPOSOPC",oCNDPROPIET,.T.)});
            ACTION EJECUTAR("BRWSELCOLORFIELD",oCNDPROPIET,.T.)

    oBtn:cToolTip:="Personalizar Colores en los Campos"

    oCNDPROPIET:oBtnColor:=oBtn

ENDIF

IF oCNDPROPIET:lBtnSave

      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             FILENAME "BITMAPS\XSAVE.BMP";
             TOP PROMPT "Grabar";
             ACTION  EJECUTAR("DPBRWSAVE",oCNDPROPIET:oBrw,oCNDPROPIET:oFrm)
ENDIF

IF oCNDPROPIET:lBtnMenuBrw

 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BRWMENU.BMP",NIL,"BITMAPS\BRWMENUG.BMP";
          TOP PROMPT "Menú";
          ACTION (EJECUTAR("BRWBUILDHEAD",oCNDPROPIET),;
                  EJECUTAR("DPBRWMENURUN",oCNDPROPIET,oCNDPROPIET:oBrw,oCNDPROPIET:cBrwCod,oCNDPROPIET:cTitle,oCNDPROPIET:aHead));
          WHEN !Empty(oCNDPROPIET:oBrw:aArrayData[1,1])

   oBtn:cToolTip:="Menú de Opciones"

ENDIF


IF oCNDPROPIET:lBtnFind

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          TOP PROMPT "Buscar";
          ACTION EJECUTAR("BRWSETFIND",oCNDPROPIET:oBrw)

   oBtn:cToolTip:="Buscar"
ENDIF

IF oCNDPROPIET:lBtnFilters

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          TOP PROMPT "Filtrar";
          MENU EJECUTAR("BRBTNMENUFILTER",oCNDPROPIET:oBrw,oCNDPROPIET);
          ACTION EJECUTAR("BRWSETFILTER",oCNDPROPIET:oBrw)

   oBtn:cToolTip:="Filtrar Registros"
ENDIF

IF oCNDPROPIET:lBtnOptions

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          TOP PROMPT "Opciones";
          ACTION EJECUTAR("BRWSETOPTIONS",oCNDPROPIET:oBrw);
          WHEN LEN(oCNDPROPIET:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

ENDIF

IF oCNDPROPIET:lBtnRefresh

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          TOP PROMPT "Refrescar";
          ACTION oCNDPROPIET:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

IF oCNDPROPIET:lBtnCrystal

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          TOP PROMPT "Crystal";
          ACTION EJECUTAR("BRWTODBF",oCNDPROPIET)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"

ENDIF

IF oCNDPROPIET:lBtnExcel


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            TOP PROMPT "Excel";
            ACTION (EJECUTAR("BRWTOEXCEL",oCNDPROPIET:oBrw,oCNDPROPIET:cTitle,oCNDPROPIET:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oCNDPROPIET:oBtnXls:=oBtn

ENDIF

IF oCNDPROPIET:lBtnHtml

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          TOP PROMPT "Html";
          ACTION (oCNDPROPIET:HTMLHEAD(),EJECUTAR("BRWTOHTML",oCNDPROPIET:oBrw,NIL,oCNDPROPIET:cTitle,oCNDPROPIET:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oCNDPROPIET:oBtnHtml:=oBtn

ENDIF


IF oCNDPROPIET:lBtnPreview

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          TOP PROMPT "Preview";
          ACTION (EJECUTAR("BRWPREVIEW",oCNDPROPIET:oBrw))

   oBtn:cToolTip:="Previsualización"

   oCNDPROPIET:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRCNDPROPIET")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            TOP PROMPT "Imprimir";
            ACTION oCNDPROPIET:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oCNDPROPIET:oBtnPrint:=oBtn

   ENDIF

IF oCNDPROPIET:lBtnQuery


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          TOP PROMPT "Consultas";
          ACTION oCNDPROPIET:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oCNDPROPIET:oWnd:IsZoomed(),oCNDPROPIET:oWnd:Restore(),oCNDPROPIET:oWnd:Maximize())

   oBtn:cToolTip:="Maximizar"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          TOP PROMPT "Primero";
          ACTION (oCNDPROPIET:oBrw:GoTop(),oCNDPROPIET:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   IF oCNDPROPIET:lBtnPageDown

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\xSIG.BMP";
            TOP PROMPT "Avance";
            ACTION (oCNDPROPIET:oBrw:PageDown(),oCNDPROPIET:oBrw:Setfocus())

  ENDIF

  IF  oCNDPROPIET:lBtnPageUp

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           FILENAME "BITMAPS\xANT.BMP";
           TOP PROMPT "Anterior";
           ACTION (oCNDPROPIET:oBrw:PageUp(),oCNDPROPIET:oBrw:Setfocus())
  ENDIF

ENDIF

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          TOP PROMPT "Ultimo";
          ACTION (oCNDPROPIET:oBrw:GoBottom(),oCNDPROPIET:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar";
          ACTION oCNDPROPIET:Close()

  oCNDPROPIET:oBrw:SetColor(0,oCNDPROPIET:nClrPane1)

/*
  IF oDp:lBtnText
     oCNDPROPIET:SETBTNBAR(oDp:nBtnHeight,oDp:nBtnWidth+3,oBar)
  ELSE
     oCNDPROPIET:SETBTNBAR(40,40,oBar)
  ENDIF
*/


  EVAL(oCNDPROPIET:oBrw:bChange)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oCNDPROPIET:oBar:=oBar

  oBar:SetSize(NIL,100,.T.)
  nLin:=40

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 BOLD

  @ nLin+27,nCol+015 SAY " "+oCNDPROPIET:cCenCos+" "+SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",oCNDPROPIET:cCenCos)) OF oBar;
                     BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont SIZE 280+140,24 PIXEL 


  

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

  oRep:=REPORTE("BRCNDPROPIET",cWhere)
  oRep:cSql  :=oCNDPROPIET:cSql
  oRep:cTitle:=oCNDPROPIET:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oCNDPROPIET:oPeriodo:nAt,cWhere

  oCNDPROPIET:nPeriodo:=nPeriodo


  IF oCNDPROPIET:oPeriodo:nAt=LEN(oCNDPROPIET:oPeriodo:aItems)

     oCNDPROPIET:oDesde:ForWhen(.T.)
     oCNDPROPIET:oHasta:ForWhen(.T.)
     oCNDPROPIET:oBtn  :ForWhen(.T.)

     DPFOCUS(oCNDPROPIET:oDesde)

  ELSE

     oCNDPROPIET:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oCNDPROPIET:oDesde:VarPut(oCNDPROPIET:aFechas[1] , .T. )
     oCNDPROPIET:oHasta:VarPut(oCNDPROPIET:aFechas[2] , .T. )

     oCNDPROPIET:dDesde:=oCNDPROPIET:aFechas[1]
     oCNDPROPIET:dHasta:=oCNDPROPIET:aFechas[2]

     cWhere:=oCNDPROPIET:HACERWHERE(oCNDPROPIET:dDesde,oCNDPROPIET:dHasta,oCNDPROPIET:cWhere,.T.)

     oCNDPROPIET:LEERDATA(cWhere,oCNDPROPIET:oBrw,oCNDPROPIET:cServer,oCNDPROPIET)

  ENDIF

  oCNDPROPIET:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oCNDPROPIET:cWhereQry)
       cWhere:=cWhere + oCNDPROPIET:cWhereQry
     ENDIF

     oCNDPROPIET:LEERDATA(cWhere,oCNDPROPIET:oBrw,oCNDPROPIET:cServer,oCNDPROPIET)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer,oCNDPROPIET,cCenCos)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb:=OpenOdbc(oDp:cDsnData),oTable,cWhereLoc:=""
   LOCAL nAt,nRowSel

   DEFAULT cWhere:=""

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

   oDb:EXECUTE([UPDATE DPCLIENTES SET CLI_RIF=CLI_CODIGO WHERE CLI_RIF IS NULL OR CLI_RIF=""])

   IF COUNT("DPCLIENTESREC")>1
     cWhereLoc:=" AND CRC_CENCOS"+GetWhere("=",cCenCos)
   ENDIF

   cSql:=" SELECT  "+;
          " CLI_RIF, "+;
          " CLI_NOMBRE, "+;
          " CLI_TEL1, "+;
          " CLI_TEL2,"+;
          " CLI_EMAIL, "+;
          " CRC_ID, "+;
          " CRC_USO "+;
          " FROM DPCLIENTES   "+;
          " LEFT JOIN DPCLIENTESREC ON CRC_CODIGO=CLI_CODIGO "+cWhereLoc+;
          " WHERE LEFT(CLI_SITUAC,1)='A' "+;
          " ORDER BY CLI_NOMBRE"+;
""

// ? cSql

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

   DPWRITE("TEMP\BRCNDPROPIET.SQL",cSql)

   // aData:=ASQL(cSql,oDb)

   oTable     :=OpenTable(cSql,.T.)
   aData      :=ACLONE(oTable:aDataFill)
   oDp:aFields:=ACLONE(oTable:aFields)
   oTable:End(.T.)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','','',0})
   ENDIF

   

   IF ValType(oBrw)="O"

      oCNDPROPIET:cSql   :=cSql
      oCNDPROPIET:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      // oBrw:nArrayAt  :=1
      // oBrw:nRowSel   :=1

      // JN 15/03/2020 Sustituido por BRWCALTOTALES
      EJECUTAR("BRWCALTOTALES",oBrw,.F.)

      nAt    :=oBrw:nArrayAt
      nRowSel:=oBrw:nRowSel

      oBrw:Refresh(.F.)
      oBrw:nArrayAt  :=MIN(nAt,LEN(aData))
      oBrw:nRowSel   :=MIN(nRowSel,oBrw:nRowSel)
      AEVAL(oCNDPROPIET:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oCNDPROPIET:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRCNDPROPIET.MEM",V_nPeriodo:=oCNDPROPIET:nPeriodo
  LOCAL V_dDesde:=oCNDPROPIET:dDesde
  LOCAL V_dHasta:=oCNDPROPIET:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oCNDPROPIET)
RETURN .T.

/*
// Ejecución Cambio de Linea
*/
FUNCTION BRWCHANGE()
  LOCAL nAt:=oCNDPROPIET:oBrw:nArrayAt
  
  oCNDPROPIET:aLineCopy:=ACLONE(oCNDPROPIET:oBrw:aArrayData[oCNDPROPIET:oBrw:nArrayAt])

  IF oCNDPROPIET:lNewRecord .AND. !oCNDPROPIET:lSaved

    oCNDPROPIET:oBrw:bChange:=NIL
    ARREDUCE(oCNDPROPIET:oBrw:aArrayData,LEN(oCNDPROPIET:oBrw:aArrayData))
    oCNDPROPIET:oBrw:Refresh(.F.)
    oCNDPROPIET:oBrw:bChange:={||oCNDPROPIET:BRWCHANGE()}
    oCNDPROPIET:oBrw:nArrayAt:=nAt

  ENDIF

  oCNDPROPIET:lNewRecord:=.F.

RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oCNDPROPIET")="O" .AND. oCNDPROPIET:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oCNDPROPIET:cWhere_),oCNDPROPIET:cWhere_,oCNDPROPIET:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oCNDPROPIET:LEERDATA(oCNDPROPIET:cWhere_,oCNDPROPIET:oBrw,oCNDPROPIET:cServer,oCNDPROPIET)
      oCNDPROPIET:oWnd:Show()
      oCNDPROPIET:oWnd:Restore()

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

   oCNDPROPIET:aHead:=EJECUTAR("HTMLHEAD",oCNDPROPIET)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

// Restaurar Parametros
FUNCTION BRWRESTOREPAR()
  EJECUTAR("BRWRESTOREPAR",oCNDPROPIET)
RETURN .T.

// Restaurar Parametros
FUNCTION BRWGETWHERE()
  LOCAL aLine     :=oCNDPROPIET:oBrw:aArrayData[oCNDPROPIET:oBrw:nArrayAt]
  LOCAL cWhere    :="PDC_CODIGO"+GetWhere("=",aLine[oCNDPROPIET:COL_CLI_RIF])+" AND PDC_ID"+GetWhere("=",aLine[oCNDPROPIET:COL_CRC_ID])

// ? cWhere

RETURN cWhere


FUNCTION VALRIF(oCol,uValue,nCol,nKey)
  LOCAL oTable,cCtaOld:="",cDescri,cWhere:=BRWGETWHERE()
  LOCAL cNombre:="",cEmail:=""
//  LOCAL cCodIni:=ALLTRIM(oCol:oBrw:aArrayData[1,oCNDPROPIET:COL_CLI_RIF])
//  LOCAL nLen   :=LEN(cCodIni)
//  LOCAL lZero  :=ISALLDIGIT(cCodIni)
 
  DEFAULT nKey:=0

  DEFAULT oCol:lButton:=.F.

  IF oCol:lButton=.T.
     oCol:lButton:=.F.
     RETURN .T.
  ENDIF

//  IF lZero .AND. nLen<=10
//     uValue:=REPLI("0",10-LEN(ALLTRIM(uValue)))
//  ENDIF
  
  cNombre:=SQLGET("DPCLIENTES","CLI_NOMBRE,CLI_TEL1,CLI_TEL2,CLI_EMAIL","CLI_RIF"+GetWhere("=",uValue))

  oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue

  IF !Empty(cNombre)

    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol+1]:=cNombre
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol+2]:=PADR(DPSQLROW(2),20)
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol+3]:=PADR(DPSQLROW(3),20)
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol+3]:=DPSQLROW(4)
    oCol:oBrw:nColSel:=nCol+5

  ELSE
     oCol:oBrw:nColSel:=nCol+1
  ENDIF

  oCol:oBrw:DrawLine(.T.)

  IF oCNDPROPIET:lNewRecord
     oCNDPROPIET:BRWGRABAR()
  ENDIF

RETURN .T.

/*
// GUARDAR VALOR EN EL CAMPO
*/
FUNCTION PUTFIELDVALUE(oCol,uValue,nCol,nKey,nLen,lNext,lTotal,lSave)
   LOCAL cField,aLine
   LOCAL cWhere:="" // oCNDPROPIET:BRWGETWHERE()

   DEFAULT nCol  :=oCol:nPos,;
           lNext :=.F.,;
           lTotal:=!Empty(oCol:cFooter),;
           lSave :=.F.

   // cField:=oCNDPROPIET:aFields[nCol,1]
   oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol  ]:=uValue
   oCNDPROPIET:oBrw:DrawLine(.T.)

   // aLine :=oCNDPROPIET:oBrw:aArrayData[oCNDPROPIET:oBrw:nArrayAt]
   // Avanza
   IF oCNDPROPIET:oBrw:nColSel<LEN(oCNDPROPIET:oBrw:aCols)

      IF oCNDPROPIET:lNewRecord
         oCNDPROPIET:oBrw:nColSel:=oCNDPROPIET:oBrw:nColSel+1
      ENDIF

   ELSE

      lSave:=.T.  // DEBE GRABAR EN TODO MOMENTO oCNDPROPIET:lNewRecord

   ENDIF

   // Graba en caliente
   IF !Empty(aLine[1])
     oCNDPROPIET:BRWGRABAR() 
   ENDIF

   IF lSave

      IF oCNDPROPIET:BRWGRABAR()
         oCNDPROPIET:BRWADDNEWLINE()
      ENDIF

   ENDIF

RETURN .T.

FUNCTION BRWGRABAR()
  LOCAL aLine  :=oCNDPROPIET:oBrw:aArrayData[oCNDPROPIET:oBrw:nArrayAt]
  LOCAL cRif   :=aLine[oCNDPROPIET:COL_CLI_RIF]
  LOCAL cNombre:=aLine[oCNDPROPIET:COL_CLI_NOMBRE]
  LOCAL cTel1  :=aLine[oCNDPROPIET:COL_CLI_TEL1]
  LOCAL cTel2  :=aLine[oCNDPROPIET:COL_CLI_TEL2]
  LOCAL cEmail :=aLine[oCNDPROPIET:COL_CLI_EMAIL]
  LOCAL cId    :=aLine[oCNDPROPIET:COL_CRC_ID]
  LOCAL nAlic  :=aLine[oCNDPROPIET:COL_CRC_USO]

  LOCAL cCodigo:=SQLGET("DPCLIENTES","CLI_CODIGO","CLI_RIF"+GetWhere("=",cRif))
  LOCAL cWhere :=""
  LOCAL oTable

  IF Empty(cRif)
    oCNDPROPIET:oBrw:nColSel:=1
    RETURN .F.
  ENDIF

  cCodigo:=IF(Empty(cCodigo),cRif,cCodigo)

  EJECUTAR("CREATERECORD","DPCLIENTES",{"CLI_CODIGO","CLI_RIF" ,"CLI_NOMBRE","CLI_SITUAC","CLI_EMAIL" ,"CLI_ZONANL"},;
                                       {cCodigo     ,cRif      ,cNombre     ,"Activo"    ,cEmail      ,"N"         },;
                                        NIL,.T.,"CLI_RIF"+GetWhere("=",cRif))

  // Grabamos la propiedad
  oCNDPROPIET:aLineCopy:=IIF(Empty(oCNDPROPIET:aLineCopy),aLine,oCNDPROPIET:aLineCopy)
  cWhere:="CRC_CODIGO"+GetWhere("=",oCNDPROPIET:aLineCopy[1])+" AND "+;
          "CRC_ID"    +GetWhere("=",oCNDPROPIET:aLineCopy[6])

  oTable:=OpenTable("SELECT * FROM DPCLIENTESREC WHERE "+cWhere,.T.)

  IF oTable:RecCount()=0
     oTable:AppendBlank()
     cWhere:=""
  ENDIF

  oTable:Replace("CRC_CODIGO",cCodigo)
  oTable:Replace("CRC_CENCOS",oCNDPROPIET:cCenCos)
  oTable:Replace("CRC_USO"   ,nAlic)
  oTable:Replace("CRC_ID "   ,cId)
  oTable:Replace("CRC_ACTIVO",.T.)

  oTable:Commit(cWhere)
  oTable:End(.T.)

  oCNDPROPIET:lSaved:=.T.


RETURN Empty(cWhere)

/*
// Agrega Nueva Linea
*/
FUNCTION BRWADDNEWLINE()
  LOCAL aLine  :=ACLONE(oCNDPROPIET:oBrw:aArrayData[1])
  LOCAL nAt    :=ASCAN(oCNDPROPIET:oBrw:aArrayData,{|a,n| Empty(a[1])})
  LOCAL cCodIni:=ALLTRIM(oCol:oBrw:aArrayData[1,oCNDPROPIET:COL_CLI_RIF])
  LOCAL nLen   :=LEN(cCodIni)
  LOCAL lZero  :=ISALLDIGIT(cCodIni)

  IF nAt>0
     RETURN .F.
  ENDIF
  
  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(aLine[n])})

  IF lZero .AND. nLen<=10
     cCodIni:=SQLINCREMENTAL("DPCLIENTES","CLI_RIF",NIL,NIL,NIL,.T.,10)
     aLine[1]:=PADR(cCodIni,15)
  ENDIF

  AADD(oCNDPROPIET:oBrw:aArrayData,ACLONE(aLine))

  EJECUTAR("BRWCALTOTALES",oCNDPROPIET:oBrw,.F.)

  oCNDPROPIET:oBrw:nColSel:=1
  oCNDPROPIET:oBrw:GoBottom()
  oCNDPROPIET:oBrw:Refresh(.F.)
  oCNDPROPIET:oBrw:nArrayAt:=LEN(oCNDPROPIET:oBrw:aArrayData)
  oCNDPROPIET:aLineCopy:=ACLONE(aLine)

  DPFOCUS(oCNDPROPIET:oBrw)

  oCNDPROPIET:lSaved:=.F.
  oCNDPROPIET:lNewRecord:=.T. 

RETURN .T.

FUNCTION BRWDELETE()
  LOCAL aLine  :=oCNDPROPIET:oBrw:aArrayData[oCNDPROPIET:oBrw:nArrayAt]
  LOCAL cCodigo:=aLine[oCNDPROPIET:COL_CLI_RIF]
  LOCAL cId    :=aLine[oCNDPROPIET:COL_CRC_ID]
  LOCAL cWhere :="CRC_CODIGO"+GetWhere("=",cCodigo)+" AND CRC_ID"+GetWhere("=",cId)
  LOCAL nAt    :=oCNDPROPIET:oBrw:nArrayAt

  IF !MsgNoYes("Desea Eliminar Cliente "+cCodigo)
     RETURN .F.
  ENDIF

  // REMOVER EL RECURSOS
  SQLDELETE("DPCLIENTESREC",cWhere)
  cWhere :="CRC_CODIGO"+GetWhere("=",cCodigo)

  IF COUNT("DPCLIENTESREC",cWhere)=0
    SQLDELETE("DPCLIENTES","CLI_RIF"+GetWhere("=",cCodigo))
    AUDITAR("DELI" , NIL ,"DPCLIENTES", cCodigo)
  ELSE
    oCNDPROPIET:BRWREFRESCAR()
    RETURN .T.
  ENDIF

  ARREDUCE(oCNDPROPIET:oBrw:aArrayData,nAt)
  IF Empty(oCNDPROPIET:oBrw:aArrayData)
    nAt:=1
    oCNDPROPIET:BRWADDNEWLINE()
  ELSE
    oCNDPROPIET:oBrw:Refresh(.F.)
  ENDIF

  oCNDPROPIET:oBrw:nArrayAt:=nAt

 
RETURN .T.
//
