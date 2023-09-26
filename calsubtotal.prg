// Programa   : CALSUBTOTAL
// Fecha/Hora : 26/09/2023 15:17:09
// Propósito  : Calcular Sub-Total
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oBrw,nColSub)
  LOCAL nAt1,I,nRowSel:=oBrw:nArrayAt,nDesde:=0,nHasta:=0
  LOCAL aSubTotal:={},aTotal:={},aLine:={}

  nDesde:=oBrw:nArrayAt
  nHasta:=oBrw:nArrayAt

  WHILE nDesde>1 .AND. !"Sub-"$oBrw:aArrayData[nDesde,nColSub]
     nDesde--
  ENDDO

  WHILE nHasta<LEN(oBrw:aArrayData) .AND. !"Sub-"$oBrw:aArrayData[nHasta,nColSub]
     nHasta++
  ENDDO
  nHasta--

  FOR I=nDesde TO nHasta
     AADD(aSubTotal,oBrw:aArrayData[I])
  NEXT I

  aTotal:=ATOTALES(aSubTotal)
  aLine :=oBrw:aArrayData[nHasta+1]

  FOR I=1 TO LEN(aLine)

     IF ValType(aLine[I])="N" .AND. !Empty(oBrw:aCols[I]:cFooter)
        aLine[I]:=aTotal[I]
     ENDIF

  NEXT I

  oBrw:nArrayAt:=nHasta+1
  oBrw:aArrayData[nHasta+1]:=ACLONE(aLine)
  oBrw:Refresh(.F.)

  oBrw:nArrayAt:=nRowSel

  // Calcular totales en el footers
  aSubTotal:={}
  AEVAL(oBrw:aArrayData,{|a,n| IF("Sub-"$a[nColSub],AADD(aSubTotal,a),NIL)})
  aTotal:=ATOTALES(aSubTotal)

  EJECUTAR("BRWCALTOTALES",oBrw,.F.,aTotal)

RETURN .T.
// EOF
