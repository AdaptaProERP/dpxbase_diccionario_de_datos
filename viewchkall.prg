// Programa   : VIEWCHKALL
// Fecha/Hora : 01/10/2023 09:01:34
// Propósito  : Revisa si Existen todas las Vistas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDb,lCreate)
  LOCAL oDb,aNew:={},nAt,I
  LOCAL aVistas,aView:=ACLONE(oDp:aVistas)

  DEFAULT lCreate:=.T.,;
          cDb    :=oDp:cDsnData


// lCreate:=.F.


  IF cDb=oDp:cDsnData
    ADEPURA(aView,{|a,n| LEFT(a[3],1)="." })
  ELSE
    ADEPURA(aView,{|a,n|!LEFT(a[3],1)="." })
  ENDIF

  oDb    :=OpenOdbc(cDb)
  aVistas:=ACLONE(oDb:GetTables())


  // Verificacion rapida de vistas.
  //  oDp:lDropAllView:=.T.

  FOR I=1 TO LEN(aView)
     nAt:=ASCAN(aVistas,{|a,n| UPPER(a)==UPPER(aView[I,2]) })
     IF(nAt=0,AADD(aNew,aView[I,1]),NIL)
  NEXT I

  IF LEN(aNew)>0 .AND. lCreate

    DpMsgRun("Procesando","Vistas en Base de Datos: "+cDb,NIL,LEN(aNew))
    DpMsgSetTotal(LEN(aNew))

    FOR I=1 TO LEN(aNew)
      DpMsgSet(I,.T.,NIL,"Creando Vistas "+aNew[I]+" "+LSTR(RATA(I,LEN(aNew)))+"%")
      EJECUTAR("ISVISTA",aNew[I],cDb,NIL,.T.)
      EJECUTAR("SETVISTAS",cDb ,aNew[I] ,NIL   ,.T.,NIL , NIL ,NIL ,cDb)
    NEXT I

  ENDIF

// ViewArray(aNew)

RETURN aNew
// EOF
