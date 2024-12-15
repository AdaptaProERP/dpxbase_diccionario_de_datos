// Programa   : WEBNOCOPY
// Fecha/Hora : 15/12/2024 04:54:01
// Propósito  : Copiar Contenido desde una Pagina Web para editarla con Word
// Creado Por : Juan Navas
// Llamado por: EJECUTAR COMANDO
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cUrl)

  DEFAULT cUrl:="https://finanzasdigital.com/gaceta-oficial-extraordinaria-6805/"

  lMkDir("download")

  DPEDIT():New("Copiar Contenido desde Web protegidas para copiar","WEBTOWORD.EDT","oWebNoCopy",.T.)
 
  oWebNoCopy:cFile   :=CURDRIVE()+":\"+CURDIR()+"\download\URL"+F8(oDp:dFecha)+"_"+LSTR(SECONDS())+".html"
  oWebNoCopy:cUrl    :=PADR(cUrl,200) 
  oWebNoCopy:oBtnRun :=NIL
  oWebNoCopy:cUrl    :=PADR(oWebNoCopy:cUrl,120)

  @ 2,1 SAY "URL " 

  @ 2,1 GET oWebNoCopy:oUrl VAR oWebNoCopy:cUrl;
        VALID (oWebNoCopy:oBtnRun:ForWhen(.T.),.T.)
                         
  oWebNoCopy:Activate({||oWebNoCopy:INICIO()})

RETURN NIL


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oWebNoCopy:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52,60 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          TOP PROMPT "Ejecutar"; 
          WHEN !Empty(oWebNoCopy:cUrl);
          ACTION oWebNoCopy:WEBLEE()

   oBtn:cToolTip:="Guardar"

   oWebNoCopy:oBtnRun:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          TOP PROMPT "Cerrar"; 
          ACTION (oWebNoCopy:Cancel()) CANCEL
   
   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

RETURN .T.

FUNCTION WEBLEE()
  LOCAL cFileMem:="TEMP\URLGETSOURCE.MEM"
  LOCAL cUrl    :=ALLTRIM(oWebNoCopy:cUrl)
  LOCAL cFile   :="TEMP\TEMP.TXT"
  LOCAL cMemo   :="",oHttp
  LOCAL aAscii  :=EJECUTAR("LOADASCIITOWEB") // Caracteres de Conversión

  SAVE TO (cFileMem) ALL LIKE "cUrl*"

  MsgRun("Leyendo "+cUrl)

  IF .T.

      oHttp:=CreateObject("winhttp.winhttprequest.5.1")
      oHttp:Open("GET",cUrl,.t.) // 04/03/2023
      oHttp:SetTimeouts(0, 60000, 30000, 120000) // https://www.autohotkey.com/boards/viewtopic.php?t=9136
      oHttp:Send()
      oHttp:WaitForResponse(90)
      cMemo:= oHttp:ResponseText()
/*
  ELSE

    WAITRUN("BIN\DPCRPE.EXE") // ,0)
 
    FERASE(cFileMem)

    IF !FILE(cFile)
       MensajeErr("No pudo Generar Archivo "+cFile)
       RETURN {}
    ENDIF

    cMemo:=MEMOREAD(cFile)
*/
  ENDIF

  
  /*
  // Resolvemos los Acentos
  */
  AEVAL(aAscii,{|a,n| cMemo:=STRTRAN(cMemo,CHR(a[1]),a[2])})

  /*
  // Desactivamos las funcion de Javascript que no permiten copiar  su contenido
  */

  cMemo:=STRTRAN(cMemo,"javascript","javascript_inactivo")
  cMemo:=STRTRAN(cMemo,"onclick"   ,"onclick_inactivo")
  cMemo:=STRTRAN(cMemo,":none"     ,":nonone")

  IF LEN(cMemo)>1
    DPWRITE(oWebNoCopy:cFile,cMemo)
    MsgRun("Abriendo Archivo ","Abriendo "+oWebNoCopy:cFile,{|| SHELLEXECUTE(oDp:oFrameDp:hWND,"open",oWebNoCopy:cFile)})
  ENDIF

RETURN .T.

FUNCTION ONCHANGE()
RETURN NIL

