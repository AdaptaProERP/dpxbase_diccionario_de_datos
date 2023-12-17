// Programa   : ARRAYSAVE
// Fecha/Hora : 17/12/2023 10:42:00
// Propósito  : Guardar Arreglos en Disco y luego recuperarlo
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cFile:="temp\arreglo.txt"
  LOCAL aData:=ASQL("SELECT * FROM DPMENU")
  LOCAL cData:=ASave( aData ) // Convierte en Texto

  ViewArray(aData)

  DPWRITE(cFile,cData)

  // Vaciamos las Variables
  cData:=NIL
  aData:=NIL

  cData:=MemoRead(cFile)
  aData:=ARead( cData)
  ViewArray(aData)

RETURN 
// EOF
