// Programa   : DPTABLAACENTOS
// Fecha/Hora : 21/08/2019 13:59:01
// Prop�sito  : Resuelve Acentos Recuperacion de Respaldos con diferentes CHARSET entre servidores
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cField,cKey)
  LOCAL aData:={},I,oTable,cWhere:="",cSql,cValue,cCodigo


  DEFAULT cTable:="DPTIPDOCCLI",;
          cField:="TDC_DESCRI",;
          cKey  :="TDC_TIPO"

  AADD(aData,{"ó","�"})
  AADD(aData,{"ía","�"})
  AADD(aData,{"é","�"})
  AADD(aData,{"ú","�"})
  AADD(aData,{"ñ","�"})
  AADD(aData,{"�"+CHR(173),"�"})
  AADD(aData,{"á","�"})
  AADD(aData,{"�"+CHR(226),"�"})
  AADD(aData,{"Ñ","�"})


  FOR I=1 TO LEN(aData)
     cWhere:=cWhere+IF(Empty(cWhere),""," OR ")+cField+GetWhere("  LIKE ","%"+aData[I,1]+"%")
  NEXT I

  FOR I=1 TO LEN(aData)
     cWhere:=cWhere+IF(Empty(cWhere),""," OR ")+cKey+GetWhere("  LIKE ","%"+aData[I,1]+"%")
  NEXT I

  cSql:=" SELECT "+cField+","+cKey+" FROM "+cTable+" WHERE "+cWhere 

  oTable:=OpenTable(cSql,.t.)
  
  WHILE !oTable:Eof() 

     cValue:=oTable:FieldGet(cField)
     cWhere:=cKey+GetWhere("=",oTable:FieldGet(cKey))
     AEVAL(aData,{|a,n| cValue:=STRTRAN(cValue,a[1],a[2])})

     SQLUPDATE(cTable,cField,cValue,cWhere)

     // CODIGO 29/06/2023
     cCodigo:=oTable:FieldGet(cKey)
     AEVAL(aData,{|a,n| cCodigo:=STRTRAN(cCodigo,a[1],a[2])})

     IF ALLTRIM(cCodigo)<>ALLTRIM(oTable:FieldGet(cKey))
        SQLUPDATE(cTable,cKey,cCodigo,cWhere)
     ENDIF
     
     oTable:DbSkip()

  ENDDO

  oTable:End()
  
  SysRefresh(.t.)

RETURN NIL

