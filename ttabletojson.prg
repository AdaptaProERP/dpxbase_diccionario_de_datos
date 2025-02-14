// Programa   : TTABLETOJSON 
// Fecha/Hora : 14/01/2025 11:50:25
// Propósito  : Crear JSON de Table
// Creado Por : Juan Navas
// Llamado por: DPDOCCLIIMPDIG
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oTable)
   LOCAL cJson:="",cLine:=""

   IF oTable=NIL
      RETURN ""
   ENDIF

   IF ValType(oTable)="C"
      oTable:=OpenTable(oTable,.T.)
   ENDIF

   WHILE !oTable:Eof()

     cLine:=""
     AEVAL(oTable:aFields,{|a,n,cField,cSep| cSep  :=IF(a[2]="N","",["]),;
                                             cField:=["]+LOWER(a[1])+[": ]+cSep+CTOO(oTable:FieldGet(n),"C")+cSep,;
                                             cLine :=cLine+IF(Empty(cLine),"",","+CRLF)+cField})

     IF Empty(cJson)
        cJson:=cLine
     ENDIF

     oTable:DbSkip()

   ENDDO

   cJson:="{"+CRLF+cJson+CRLF+"}"

RETURN cJson
// EOF
