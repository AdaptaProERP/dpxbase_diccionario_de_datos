// Programa   : DELDIRADPTMP
// Fecha/Hora : 26/09/2023 05:32:29
// Prop�sito  : Remover Carpetas Temporales 
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

  EJECUTAR("DELDIR","20*.*")
  EJECUTAR("DELDIR","UNIQUE_*.*")
  EJECUTAR("DELDIR","TABLEDROP*.*")
  EJECUTAR("DELDIR","RECORDNULL*.*")
  EJECUTAR("DELDIR","RELEASE*.*")
  EJECUTAR("DELDIR","QUERY*.*")
  EJECUTAR("DELDIR","UPLOAD")


RETURN .T.
// EOF

