// Programa   : GETWHERELIKE
// Fecha/Hora : 20/07/2023 04:07:39
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cField,cText,cFieldC)
   LOCAL aText,I,cWhere:="",cWhereS:="",cWhereA:="",nCant,cWhereA

   DEFAULT cTable :="DPCLIENTES",;
           cField :="CLI_NOMBRE",;
           cText  :="CLINICA MERCE",;
           cFieldC:="CLI_CODIGO"

   IF !Empty(cFieldC) .AND. ISSQLFIND(cTable,cFieldC+GetWhere("=",cText))
      RETURN cFieldC+GetWhere("=",cText)
   ENDIF

   cText:=ALLTRIM(cText)
   aText:=_VECTOR(cText," ")



   ADEPURA(aTexT,{|a,n| Empty(a)})
  
   IF LEN(aText)=1

     cWhere:=cField+" LIKE "+GetWhere("","%"+cText+"%")

     nCant :=COUNT(cTable,cWhere)
     cWhereS:=EJECUTAR("FINDSOUND",cText,cField,"LIKE")

     // Busca de manera Incremental el registro mas cercano, si escribe CLINICAS (Buscará CLINICA)
     WHILE LEN(cText)>10 .AND. nCant=0
        cText :=LEFT(cText,LEN(cText)-1)
        cWhere:=cField+" LIKE "+GetWhere("","%"+cText+"%")
        nCant :=COUNT(cTable,cWhere)
     ENDDO

    // cWhereS:=EJECUTAR("FINDSOUND",cText,cField,"LIKE")

    cWhere:= cWhere+" OR "+cWhereS

    //? CLPCOPY(cWhere)

   ELSE

     FOR I=1 TO LEN(aText)

       cWhere:=cWhere+IF(Empty(cWhere),""," OR ")+;
               cField+" LIKE "+GetWhere("","%"+aText[I]+"%")

       cWhereA:=cWhereA+IF(Empty(cWhereA),""," AND ")+;
                cField+" LIKE "+GetWhere("","%"+aText[I]+"%")

     NEXT I

     IF COUNT(cTable,cWhereA)>0
//      ? cWhereA,"buscar and ENCONTRADO"
        cWhere:=cWhereA
     ENDIF

   ENDIF

RETURN cWhere
// EOF
