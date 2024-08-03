// Programa   : SETCODSUC
// Fecha/Hora : 02/08/2024 05:20:27
// Propósito  : Asignar Código de Sucursal 
// Creado Por : Juan Navas
// Llamado por: DPSU
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cSucIni,cSucFin)
     LOCAL aFields:=ASQL("SELECT CAM_TABLE,CAM_NAME FROM DPCAMPOS WHERE RIGHT(CAM_NAME,6)"+GetWhere("=","CODSUC")+[ AND LEFT(CAM_TABLE,5)<>"VIEW_"])
     LOCAL oDb    :=OpenOdbc(oDp:cDsnData)
     LOCAL cSql,I,cWhere

     DEFAULT cSucIni:=oDp:cSucursal,;
             cSucFin:="000002"

     cSql:=" SET FOREIGN_KEY_CHECKS = 0"
     oDb:Execute(cSql)

     FOR I=1 TO LEN(aFields)
         cWhere:=aFields[I,2]+GetWhere("=",cSucIni)
         SQLUPDATE(aFields[I,1],aFields[I,2],cSucFin,cWhere)
     NEXT I

/*
       cSql:=[ SELECT DAT_GROUP, CONCAT(LEFT(DAT_GROUP,LENGTH(DAT_GROUP)-6),]+GetWhere("",cSucFin)+[)]+;
             [ FROM DPDATASET ]+;
             [ WHERE LEFT(DAT_GROUP,4)="SUC_" AND RIGHT(DAT_GROUP,6)]+GetWhere("=",cSucIni)
*/

       cSql:=[ UPDATE DPDATASET ]+CRLF+;
             [ SET DAT_GROUP=CONCAT(LEFT(DAT_GROUP,LENGTH(DAT_GROUP)-6),]+GetWhere("",cSucFin)+[)]+CRLF+;
             [ WHERE LEFT(DAT_GROUP,4)="SUC_" AND RIGHT(DAT_GROUP,6)]+GetWhere("=",cSucIni)

     oDb:Execute(cSql)
 

     cSql:=" SET FOREIGN_KEY_CHECKS = 1"
     oDb:Execute(cSql)

RETURN .T.
// EOF

