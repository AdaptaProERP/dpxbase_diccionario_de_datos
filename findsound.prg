// Programa   : FINDSOUND
// Fecha/Hora : 15/05/2013 16:12:38
// Propósito  : Generar Texto de Búsqueda según expresion de sonido
// Creado Por : Juan Navas
// Llamado por: GETWHERELIKE        
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cText,cField,cOper)
   LOCAL cWhere:="",aText:={},I,aNewT:={},aDos:={}

   DEFAULT oDp:aSound:={},;
           cField:="CLI_NOMBRE",;
           cText :="HUGO CAMESELLA PC",;
           cOper :="="

   aText:=_VECTOR(ALLTRIM(cText)," ")

// VIEWARRAY(aText)

   ADEPURA(aText,{|a,n| Empty(a)})

   IF Empty(oDp:aSound) .OR. .T.

     oDp:aSound:={}
     AADD(oDp:aSound,{"í" ,"I"})
     AADD(oDp:aSound,{"N" ,"Ñ"})
     AADD(oDp:aSound,{"n" ,"ñ"})
     AADD(oDp:aSound,{"Ñ" ,"N"})
     AADD(oDp:aSound,{"ñ" ,"n"})

     AADD(oDp:aSound,{"Z" ,"S"})
     AADD(oDp:aSound,{"LL","Y"})
     AADD(oDp:aSound,{"H" ,"" })
     AADD(oDp:aSound,{"C","K" })
     AADD(oDp:aSound,{"V","B" })

     AADD(oDp:aSound,{"SS","S" })

     AADD(oDp:aSound,{"S","SS" })


     AADD(oDp:aSound,{"NH","Ñ" })
     AADD(oDp:aSound,{"Ñ","NH" })

     AADD(oDp:aSound,{"KA","CA" })
     AADD(oDp:aSound,{"KE","CE" })
     AADD(oDp:aSound,{"KI","CI" })
     AADD(oDp:aSound,{"KO","CO" })
     AADD(oDp:aSound,{"KU","CU" })

     AADD(oDp:aSound,{"XA","JA" })
     AADD(oDp:aSound,{"XE","JE" })
     AADD(oDp:aSound,{"XI","JI" })
     AADD(oDp:aSound,{"XO","JO" })
     AADD(oDp:aSound,{"XU","JU" })


     AADD(oDp:aSound,{"CA","KA" })
     AADD(oDp:aSound,{"CE","KE" })
     AADD(oDp:aSound,{"CI","KI" })
     AADD(oDp:aSound,{"CO","KO" })
     AADD(oDp:aSound,{"CU","KU" })

     AADD(oDp:aSound,{"CA","SA" })
     AADD(oDp:aSound,{"CE","SE" })
     AADD(oDp:aSound,{"CI","SI" })
     AADD(oDp:aSound,{"CO","SO" })
     AADD(oDp:aSound,{"CU","SU" })
     AADD(oDp:aSound,{"CE","Cé" })

     AADD(oDp:aSound,{"GA","YA" })
     AADD(oDp:aSound,{"GE","YE" })
     AADD(oDp:aSound,{"GI","YI" })
     AADD(oDp:aSound,{"GO","YO" })
     AADD(oDp:aSound,{"GU","YU" })

     AADD(oDp:aSound,{"YA","GA" })
     AADD(oDp:aSound,{"YE","GE" })
     AADD(oDp:aSound,{"YI","GI" })
     AADD(oDp:aSound,{"YO","GO" })
     AADD(oDp:aSound,{"YU","GU" })

     AADD(oDp:aSound,{"YA","JA" })
     AADD(oDp:aSound,{"YE","JE" })
     AADD(oDp:aSound,{"YI","JI" })
     AADD(oDp:aSound,{"YO","JO" })
     AADD(oDp:aSound,{"YU","JU" })

     AADD(oDp:aSound,{"JA","GA" })
     AADD(oDp:aSound,{"JE","GE" })
     AADD(oDp:aSound,{"JI","GI" })
     AADD(oDp:aSound,{"JO","GO" })
     AADD(oDp:aSound,{"JU","GU" })

     AADD(oDp:aSound,{" CA"," C.A." })


   ENDIF
  
   AEVAL(aText,{|a,n|aText[n]:=UPPE(a)})

   // Buscamos textos de dos o digitos y le agregamos una coma y un punto

   FOR I=1 TO LEN(aText)

      IF LEN(aText[I])>3 .AND. "."$aText[I]
         AADD(aDos,STRTRAN(aText[I],".",""))
      ENDIF

      IF LEN(aText[I])>3 .AND. ","$aText[I]
         AADD(aDos,STRTRAN(aText[I],",",""))
      ENDIF

      IF LEN(aText[I])=2
         AADD(aDos,LEFT(aText[I],1)+","+RIGHT(aText[I],1))
         AADD(aDos,LEFT(aText[I],1)+","+RIGHT(aText[I],1)+",")
         AADD(aDos,LEFT(aText[I],1)+"."+RIGHT(aText[I],1))
         AADD(aDos,LEFT(aText[I],1)+"."+RIGHT(aText[I],1)+".")
      ENDIF

   NEXT I

   AEVAL(aDos,{|a,n|AADD(aText,a)})

   FOR I=1 TO LEN(aText)
      AEVAL(oDp:aSound,{|a,n| IF(a[1]$" "+aText[I],AADD(aNewT,STRTRAN(aText[I],a[1],a[2])),NIL) })
   NEXT I

   AEVAL(aText,{|a,n| AADD(aNewT,a)})

   aText:=ACLONE(aNewT)

   FOR I=1 TO LEN(aText)
      AEVAL(oDp:aSound,{|a,n| IF(a[1]$" "+aText[I],AADD(aNewT,STRTRAN(aText[I],a[1],a[2])),NIL) })
   NEXT I

   IF cOper="="
      cWhere:=GetWhereOr(cField,aNewT)    
   ELSE
//      AEVAL(aNewT,{|a,n| aNewT[n]:="% "+a+" %" })
      AEVAL(aNewT,{|a,n| aNewT[n]:="%"+a+"%" })
      cWhere:=GetWhereOr(cField,aNewT," LIKE ")    
   ENDIF

// ? cWhere

RETURN cWhere
// EOF
