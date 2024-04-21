// Programa   : IXLLOADREF             
// Fecha/Hora : 17/07/2023 04:42:25
// Propósito  : Devuelve las Etiquetas por Tablas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cCodigo)
  LOCAL aRef:={},cMemoPrg:=""

  DEFAULT cTable:="DPCLIENTES"

  cTable:=ALLTRIM(cTable)

  IF !Empty(cCodigo)

     cMemoPrg:=SQLGET("DPIMPRXLS","IXL_ETQPRG","IXL_CODIGO"+GetWhere("=",cCodigo))

      IF !Empty(cMemoPrg)
         aRef:=EJECUTAR("RUNMEMO",cMemoPrg,cCodigo)
      ENDIF

      IF !Empty(aRef) .AND. ValType(aRef)="A"
         RETURN aRef
      ENDIF

  ENDIF

  IF cTable=="DPCLIENTES"
     aRef:=EJECUTAR("IMPCLIXLS",.T.)
  ENDIF

  IF cTable=="DPCLIENTESREC"
     aRef:=EJECUTAR("IMPCLIENTESRECXLS",.T.)
  ENDIF

  IF cTable="DPINV"
     aRef:=EJECUTAR("IMPEXPINVXLS",.T.)
  ENDIF

  IF cTable="DPASIENTOS"
    aRef:=EJECUTAR("DPIMPRXLSASIENTOSXLS",.T.)
  ENDIF

RETURN aRef
// EOF
