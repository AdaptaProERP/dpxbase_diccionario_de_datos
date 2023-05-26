// Programa   : NMCONCEPTOSDOWNLOAD
// Fecha/Hora : 26/05/2023 02:40:05
// Propósito  : Descargar Conceptos desde http://191.96.151.60/~ftp16402/descargas/nomina/a200.prg
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodCon)
    LOCAL cUrl,cSaveAs,cUrl2,cWeb,cIp,cMemo:="",oConcepto,aData:={}

    DEFAULT cCodCon:="A200"

    cUrl   :="http://191.96.151.60/~ftp16402/descargas/nomina/"+lower(cCodCon)+".prg"
    cSaveAs:=oDp:cBin+"temp\"+cCodCon+".prg"

    ferase(cSaveAs)
    URLDownLoad(cUrl, cSaveAs)

    IF !File(cSaveAs) 

       cUrl2:="https://github.com/AdaptaProERP/conceptos_de_nomina/blob/main/"+lower(cCodCon)+".prg"
       cWeb :="https://github.com"
       cIp  := GETHOSTBYNAME(cWeb) 

       MsgMemo("Concepto "+cUrl+" no fué descargado"+CRLF+"Será ejecutado sitio Alternativo "+cUrl2+CRLF,"Validación",700,150)

       MsgRun("Ejecutando "+cWeb,"IP Detectada:"+cIp, {||SHELLEXECUTE(oDp:oFrameDp:hWND,"open",cUrl2)}) 

    ELSE

       cMemo:=MemoRead(cSaveAs)

    ENDIF

    oConcepto:=EJECUTAR("NMCONCEPTOS",3,cCodCon)

    IF ValType(oConcepto)="O" .AND. !Empty(cMemo)

      cMemo:=STRTRAN(cMemo,CRLF,CHR(10))
      aData:=_VECTOR(cMemo,CHR(10))
      cMemo:=""

     
      oConcepto:oCON_FORMUL:VarPut(cMemo,.T.)

      // Efecto de Transcripción 
      AEVAL(aData,{|a,n| oConcepto:oCON_FORMUL:Append(a+CRLF)})

    ENDIF

RETURN .t.
// EOF
