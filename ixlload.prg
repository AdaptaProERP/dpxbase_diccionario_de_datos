// Programa  : IXLLOAD 
// Fecha/Hora: 29/08/2010 16:17:36
// Prop¥sito : Lectura de archivo IXL
// Creado Por: Juan Navas

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cTable,aFields,cCodigo,cKey,cMemo)
  LOCAL cCol,I:=0,aSelect:={},cFileLbx,cSelect:="",nAt,N:=0,aCols:={},aKey:={}

  DEFAULT cTable :="DPINV",;
          aFields:={}

  /*
  // Aqui debe Recuperar el Archivos desde DPFILES
  */

  IF Empty(cMemo)

    IF !("."$cTable)
      cFileLbx:=oDp:cPathExe+"FORMS\"+ALLTRIM(cTable)+".IXL"
    ELSE
      cFileLbx:=cTable
    ENDIF


    IF cCodigo=NIL
      cMemo:=MEMOREAD(cFileLbx)
    ELSE
      cMemo:=SQLGET("DPIMPRXLS","IXL_MEMO","IXL_CODIGO"+GetWhere("=",cCodigo))
    ENDIF

  ENDIF

  aCols:=_VECTOR(STRTRAN(cMemo,CHR(13),""),CHR(10))
//aCols:=_VECTOR(STRTRAN(MEMOREAD(cFileLbx),CHR(13),""),CHR(10))


  WHILE .T.

     n:=LEN(aSELECT)+1

     cCol:="COL"+STRZERO(N,2)+"_HEADER"
     cCol:=XGETLBX(cCol) // Lista de Campos ya seleccionados

     IF EMPTY(cCol) 
        EXIT
     ENDIF

     AADD(aSelect,{"","","",SPACE(250)})
     // n  :=LEN(aSelect)

     nAt:=ASCAN(aFields,{|a,n| ALLTRIM(cCol)==ALLTRIM(a[1]) })

     IF nAt>0
        aSelect[n,2]:=aFields[nAt,2]
     ENDIF

     aSelect[n,1]:=cCol

     cCol:="COL"+STRZERO(n,2)+"_COLUMN"
     cCol:=XGETLBX(cCol) // Columna

     aSelect[N,3]:=cCol

     cCol:="COL"+STRZERO(n,2)+"_DEFAULT"
     cCol:=XGETLBX(cCol) // Columna

     aSelect[n,4]:=PADR(cCol,250)

     IF LEN(aSelect[n])=4
        AADD(aSelect[n],.F.)
     ENDIF

     IF LEN(aSelect[n])=5
        AADD(aSelect[n],.F.)
     ENDIF

  ENDDO

  // Asume por defecto las claves de Tabla
  // 21/02/2023
  IF Empty(aSelect) .AND. !Empty(cKey)

     aKey:=_VECTOR(cKey,",")

     FOR I=1 TO LEN(aKey)
       AADD(aSelect,{aKey[I],"",CHR(64+I),SPACE(250),.F.,.F.})
     NEXT I

  ENDIF

  oDp:aSelect:=ACLONE(aSelect)

RETURN aSelect

FUNCTION XGETLBX(cCol)
   LOCAL uValue:="",nAt

   nAt   :=ASCAN(aCols,cCol)

   IF nAt>0
     uValue:=aCols[nAt]
     nAt   :=AT("=",uValue)+1
     uValue:=SUBS(uValue,nAt,LEN(uValue))
   ENDIF

RETURN uValue
// EOF


