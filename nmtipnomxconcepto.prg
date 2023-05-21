// Programa   : NMTIPNOMXCONCEPTO
// Fecha/Hora : 21/05/2023 06:21:54
// Propósito  : Asignar Tipos de Nómina por Concepto, Optimizar Procesar nómina
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL aFields:={}
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)

  AADD(aFields,{"CXO_CODCON","C",004,0,"Concepto"      ,""})
  AADD(aFields,{"CXO_CODNOM","D",003,0,"Tipo de Nómina",""})
  AADD(aFields,{"CXO_ACTIVO","L",001,0,"Activo"        ,""})

  EJECUTAR("DPTABLEADD","NMTIPNOMXCONCEPTO","Tipo de Nómina por Concepto","<MULTIPLE>",aFields)

  // Nuevos campos
  EJECUTAR("DPCAMPOSADD","NMOTRASNM","OTR_CODNOM","C",3,0,"Código;Nómina")
  EJECUTAR("DPCAMPOSADD","NMOTRASNM","OTR_TIPDOC","C",3,0,"Tipo de Documento")

  // Actualizar contenido de OTR_CODMON segun Concatenacion de Tipo de Nomina + Otra Nómina
  oDb:EXECUTE("UPDATE NMOTRASNM SET OTR_CODNOM=CONCAT(OTR_TIPO,OTR_CODIGO)")
 
  // Crear Integridad Referencial
  EJECUTAR("DPLINKADD","NMCONCEPTOS","NMTIPNOMXCONCEPTO","CON_CODIGO","CXO_CODCON",.T.,.T.,.T.)
  EJECUTAR("DPLINKADD","NMOTRASNM"  ,"NMTIPNOMXCONCEPTO","OTR_CODNOM","CXO_CODNOM",.T.,.T.,.T.)

RETURN .T.
// EOF
