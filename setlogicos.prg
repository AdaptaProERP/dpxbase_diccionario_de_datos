// Programa   : SETLOGICOS
// Fecha/Hora : 27/07/2021 03:26:47
// Prop�sito  :
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
    LOCAL oDb:=OpenOdbc(oDp:cDsnConfig)
 
    oDp:aLogico:=ASQL("SELECT RTRIM(CAM_TABLE),CAM_NAME FROM DPCAMPOS WHERE CAM_TYPE='L' ORDER BY CAM_NAME",oDb)

RETURN .T.
// EOF

