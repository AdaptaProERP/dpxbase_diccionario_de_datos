// Programa   : INSTALLCRYSTAL_DLL
// Fecha/Hora : 26/04/2024 20:46:47
// Prop�sito  : Descargar y Ejecutar programa de instalaci�n
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cFileBin:="crystaldll.exe"
  LOCAL cDir    :="bin\"
  LOCAL cUrl    :=oDp:cUrlDownLoad+"descargas/"+cFileBin
  LOCAL cSaveAs :=oDp:cBin+"bin\"+cFileBin

  IF !MsgNoYes("Desea Instalar Crystall DLL")
     RETURN .F.
  ENDIF

  ferase(cSaveAs)
  URLDownLoad(cUrl, cSaveAs)

  IF file(cSaveAs)
     EJECUTAR("DPFIN",.T.)
     SHELLEXECUTE(oDp:oFrameDp:hWND,"open",cSaveAs)
  ENDIF

RETURN .T.
// EOF

