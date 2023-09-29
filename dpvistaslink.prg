// Programa   : DPVISTASLINK
// Fecha/Hora : 31/07/2004 21:36:44
// Propósito  : Determinar en los demás Conceptos donde Actua
// Creado Por : Juan Navas
// Llamado por: DPVISTAS.LBX
// Aplicación : Definiciones de Nómina
// Tabla      : DPVISTAS

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodVista,lMode,cDescri,lVista,lGetData)
   LOCAL cFormul:="",cSql:="",I,lFound:=.f.,cTitle:="Vistas"
   LOCAL cMsg   :=""
   LOCAL aFind  :={}
   LOCAL oTable,aCodVista:={} 

   CursorWait()
   
   DEFAULT cCodVista:=SQLGET("DPVISTAS","VIS_VISTA"),lMode:=.f.,lVista:=.T.,lGetData:=.F.

   cCodVista:=ALLTRIM(cCodVista)

   AADD(aFind,"VIEW_"+cCodVista)               // Variable

   cSql:="SELECT VIS_VISTA FROM DPVISTAS WHERE "

   FOR I=1 TO LEN(aFind)
       cSql:=cSql+IIF(I>1," OR ","")+;
             "UPPER(VIS_DEFINE) LIKE '%"+aFind[I]+"%'"+CRLF
   NEXT I

   oTable:=OpenTable(cSql,.T.)
   lFound:=(oTable:RecCount()>0)
   cSql  :=GetWhereOr("VIS_VISTA",oTable:aDataFill)

   AEVAL(oTable:aDataFill,{|a,n|AADD(aCodVista,a[1]),;
                                cMsg:=cMsg+IIF(n>1,",","")+a[1]})

   oTable:End()

   IF lGetData
      RETURN ACLONE(aCodVista)
   ENDIF

   IF !lFound .AND. lMode
      MensajeErr(cTitle+" "+cCodVista+" no Participa en Otras Vistas","Respuesta ")
      RETURN ACLONE(aCodVista)
   ENDIF

   IF lFound .AND. lMode  
      DPLBX("DPVISTAS", cTitle+"s Asociados con ["+cCodVista+"]" , cSql )
   ENDIF

   IF lFound .AND. !lMode  
      MensajeErr("Participa en "+cTilte+"(s): "+cMsg,cTitle+": "+cCodVista)
   Endif

RETURN ACLONE(aCodVista)
// EOF

