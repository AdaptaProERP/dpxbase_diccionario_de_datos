// Programa   : MENUFONT
// Fecha/Hora : 16/12/2023 05:33:56
// Propósito  : Fuente de Letra para el Menú de Opciones
// Creado Por : Juan Navas
// Llamado por: DPMENU_.PRG
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

/*
  oDp:nMenuMainClrText:=NIL
  oDp:nMenuMainClrPane:=NIL
  oDp:nMenuMainSelText:=NIL
  oDp:nMenuMainSelPane:=NIL
  oDp:nMenuBoxClrText :=NIL
*/

 DEFINE FONT oDp:oFontMenu NAME "Tahoma"   SIZE 0, -12 

RETURN oDp:oFontMenu
// EOF
