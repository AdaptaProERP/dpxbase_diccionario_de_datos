// Programa   : DELDIR
// Fecha/Hora : 26/09/2023 05:13:32
// Propósito  : Remover Contenidos de Capertas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cMask)
   LOCAL aDir:={},aFiles,I,cDir

   DEFAULT cMask:="20*.*"

   aDir:=DIRECTORY(cMask,"D")

   ADEPURA(aDir,{|a,n|!a[5]="D"})

   FOR I=1 TO LEN(aDir)

      cDir  :=aDir[I,1]+"\"
      aFiles:=DIRECTORY(cDir+"*.*")

      AEVAL(aFiles,{|a,n| FERASE(cDir+a[1])})

      DELDIR(cDir)

   NEXT I

RETURN .T.

/*
// Remover Directorio Vacio
*/

FUNCTION DELDIR(cPathName ) 
  LOCAL hDLL := If(ValType("Kernel32.Dll" ) == "N","Kernel32.Dll",LoadLibrary("Kernel32.Dll" ) ) 
  LOCAL uResult 
  LOCAL cFarProc 

  IF Abs(hDLL ) > 32 
    cFarProc:= GetProcAddress(hDLL,If(Empty("RemoveDirectoryA" ) == .t.,"RemoveDir","RemoveDirectoryA" ),.T.,5,9 ) 
    uResult := CallDLL(cFarProc,cPathName ) 
    IIF(ValType("Kernel32.Dll" ) == "N",,FreeLibrary(hDLL ) )
  ELSE 
    MsgAlert("Error code: " + LTrim(Str(hDLL ) ) + " loading " + "Kernel32.Dll" ) 
  ENDIF

RETURN uResult
// EOF
