// Programa   : DROPALLINDEX
// Fecha/Hora : 20/09/2011 15:23:05
// Propósito  : Borrar Todos los Indicese Integridad Referencial
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lConfig,oDb)
   LOCAL aTables:={},I,cSql

   DEFAULT lConfig:=.F.

   aTables:=ASQL("SELECT TAB_NOMBRE FROM DPTABLAS WHERE TAB_CONFIG"+GetWhere("=",lConfig))

   IF oDb=NIL
      oDb:=OpenOdbc(IF(lConfig,oDp:cDsnConfig,oDp:cDsnData))
   ENDIF

   cSql:=" SET FOREIGN_KEY_CHECKS = 0"
   oDb:Execute(cSql)

   DpMsgRun("Removiendo Indices","Procesando",NIL,LEN(aTables),NIL,.T.)

   FOR I=1 TO LEN(aTables)

      DpMsgSetTotal(LEN(aTables),"Removiendo","cText")

      EJECUTAR("DPGET_FK",aTables[I,1],.T.,oDb)

   NEXT I

   DpMsgClose()

   cSql:=" SET FOREIGN_KEY_CHECKS = 0"
   oDb:Execute(cSql)



RETURN NIL

