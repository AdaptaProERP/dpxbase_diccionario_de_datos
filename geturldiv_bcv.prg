// Programa   : GETURLDIV_BCV
// Fecha/Hora : 17/01/2018 00:56:46
// Propósito  : Lectura URL de Divisa desde el Banco Central
// Creado Por : Juan Navas
// Llamado por: 
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lSave,lwinhttp,lSay)
  LOCAL cFile:="TEMP\TEMP.TXT"
  LOCAL cMemo:="",nAt
  LOCAL cText:="Precio del d¢lar en Bs."
  LOCAL aData:={},I,cUrl
  LOCAL cFileMem:="TEMP\URLGETSOURCE.MEM"
  LOCAL aMes:={},lCheck:=.T.,cIp,cBs
  LOCAL dFecha:=oDp:dFecha,cWhere,cUsdBcv
  LOCAL I:=0,cAno:=LSTR(YEAR(oDp:dFecha)),cMes,cDia,oDb:=OpenOdbc(oDp:cDsnData),nValor
  LOCAL cWeb,oHttp,nContar:=0
  LOCAL oFrmHisMon


  DEFAULT lwinhttp:=.F.,;
          lSay    :=.F.

  DEFAULT oDp:cMemoUcv :="",;
          oDp:cUsdBcv  :="DBC",;
          oDp:cEurBcv  :="EBC",;
          oDp:dFechaBcv:=oDp:dFecha

  cUrl:="https://www.bcv.org.ve/"
  cWeb:=STRTRAN(cUrl,"https:/"+"/","")

  cWeb:="www.bcv.org.ve"

  CursorWait()

  WsaStartUp()

  oDp:cErp_cMsg:=""

  oDp:cMemoUcv:=""

  cIp := GETHOSTBYNAME(cWeb) // se supone que siempre esta activo

  IF "0.0.0"$cIp .AND. lCheck

       oDp:cErp_cMsg:="No hay Conexión Internet o "+cUrl+" no fué Encontrada"

       IF lSay
         MensajeErr(oDp:cErp_cMsg) // "No hay Conexión Internet o "+cUrl+" no fué Encontrada")
       ENDIF

       RETURN 0

  ENDIF

  cMemo  :=""

  IF Empty(oDp:cMemoUcv) .AND. !lwinhttp

    FERASE(cFile)

    SAVE TO (cFileMem) ALL LIKE "cUrl*"

    // 31/10/2023 Se queda colgado 

    WAITRUN("BIN\DPCRPE.EXE") // ,0)

    FERASE(cFileMem)

    IF !FILE(cFile)
       MensajeErr("No pudo Generar Archivo "+cFile)
       RETURN {}
    ENDIF

    cMemo:=MEMOREAD(cFile)

    CLPCOPY(cFile)

    oDp:cMemoUcv:=cMemo

  ENDIF

  IF lwinhttp

    EJECUTAR("MSGTEMPERR",.F.,.T.)
    cMemo  :=""
    nContar:=0

    oHttp  :=CreateObject("winhttp.winhttprequest.5.1")

    WHILE nContar++<5 .AND. Empty(cMemo)

      CursorWait()
      // oHttp:=CreateObject("winhttp.winhttprequest.5.1")
      oHttp:Open("GET","https://www.bcv.org.ve",.t.) // 04/03/2023
      oHttp:SetTimeouts(0, 60000, 30000, 120000) // https://www.autohotkey.com/boards/viewtopic.php?t=9136
      oHttp:Send()
      oHttp:WaitForResponse(90)
      cMemo:= oHttp:ResponseText()

      SysRefresh(.T.)

      IF !Empty(cMemo)
         EXIT
      ENDIF

    ENDDO

    IF !ValType(cMemo)="C"
       cMemo:=""
    ENDIF

    oHttp:End()

    IF Empty(cMemo)

      // Error WinHttp.WinHttpRequest/-1  Error de compatibilidad del canal seguro
      cMemo:=EJECUTAR("MSGTEMPERR",.T.,.T.)
      nAt  :=AT(":SEND",cMemo)

      IF nAt>0
         cMemo:=LEFT(cMemo,nAt+6)
         oFrmHisMon:=EJECUTAR("DPHISMON",1,"DBC",oDp:dFecha)
      ENDIF

     ELSE

       DpWrite("TEMP\BCVMEMO.TXT",cMemo)

     ENDIF

     oDp:cMemoUcv:=cMemo

     IF ("CONEC"$cMemo .OR. "ERROR"$UPPER(cMemo)) .AND. !"USD"$cMemo
       oDp:cErp_cMsg:="Conexión no Permitida con "+cUrl
       RETURN 0
     ENDIF

  ENDIF

  /*
  // Luego que lee el valor de la Divisa lo guarda
  */

  cMemo:=oDp:cMemoUcv
  nAt  :=AT("<span> USD</span>",cMemo)

  IF nAt>0
     cMemo:=SUBS(cMemo,nAt,180)
  ENDIF

  IF lSay 
     MsgMemo(cMemo)
  ENDIF

  cUsdBcv    :=TEXTBETWEEN(cMemo,"<strong>","</strong>") // 18/09/2024
  cUsdBcv    :=STRTRAN(cUsdBcv,".","")
  cUsdBcv    :=STRTRAN(cUsdBcv,",",".")

  oDp:nUsdBcv:=VAL(cUsdBcv)

  AADD(aMes,{"Enero"     ,"01"})
  AADD(aMes,{"Febrero"   ,"02"})
  AADD(aMes,{"Marzo"     ,"03"})
  AADD(aMes,{"Abril"     ,"04"})
  AADD(aMes,{"Mayo"      ,"05"})
  AADD(aMes,{"Junio"     ,"06"})
  AADD(aMes,{"Julio"     ,"07"})
  AADD(aMes,{"Agosto"    ,"08"})
  AADD(aMes,{"Septiembre","09"})
  AADD(aMes,{"Octubre"   ,"10"})
  AADD(aMes,{"Noviembre" ,"11"})
  AADD(aMes,{"Diciembre" ,"12"})

  AEVAL(aMes,{|a,n| aMes[n,1]:=a[1]+"  "+cAno})

  cMemo:=oDp:cMemoUcv
  nAt  :=0
  I    :=0
  WHILE I++<LEN(aMes) .AND. nAt=0
     cMes:=aMes[I,2]
     nAt :=AT(aMes[I,1],cMemo)
  ENDDO

  IF nAt>0
    cMemo :=SUBS(cMemo,nAt-03,40)
    nAt   :=AT("<",cMemo)
    cMemo :=LEFT(cMemo,nAt-1)
    cDia  :=SUBS(cMemo,1,2)
    oDp:dFechaBcv:=CTOD(cDia+"/"+cMes+"/"+LSTR(YEAR(oDp:dFecha)))
  ENDIF

  IF Empty(oDp:dFechaBcv)
     oDp:dFechaBcv:=oDp:dFecha
  ENDIF

  EJECUTAR("CREATERECORD","DPTABMON",{"MON_CODIGO","MON_DESCRI"                       ,"MON_ACTIVO","MON_APLICA"},;
                                     {oDp:cUsdBcv ,"Dolar BCV https://www.bcv.org.ve/",.T.         ,"*"         },NIL,.T.,"MON_CODIGO"+GetWhere("=",oDp:cUsdBcv))

  cWhere:="HMN_CODIGO"+GetWhere("=",oDp:cUsdBcv  )+" AND "+;
          "HMN_FECHA "+GetWhere("=",oDp:dFechaBcv)

  // Martes BCV publica el valor del dolar 04/06/2024 lunes fue feriado, hoy sabado 01 de junio no tiene valor 
  IF oDp:nUsdBcv>0 .AND. DOW(oDp:dFechaBcv)=3 .AND. (DOW(dFecha)=7 .OR. DOW(dFecha)=1)

    EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO","HMN_FECHA"  ,"HMN_HORA","HMN_VALOR"},;
                                       {oDp:cUsdBcv ,dFecha       ,"00:00:00",oDp:nUsdBcv},NIL,.T.,;
                                       "HMN_CODIGO"+GetWhere("=",oDp:cUsdBcv  )+" AND HMN_FECHA "+GetWhere("=",dFecha))

  ENDIF

  IF oDp:nUsdBcv>0

    EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO","HMN_FECHA"  ,"HMN_HORA","HMN_VALOR"},;
                                     {oDp:cUsdBcv ,oDp:dFechaBcv,"00:00:00"   ,oDp:nUsdBcv},NIL,.T.,cWhere)

  ENDIF

  // hoy domingo, lee el valor de la divisa el BCV emite la fecha el día lunes
  IF DOW(oDp:dFecha)=1 .AND. (oDp:dFecha+1=oDp:dFechaBcv)

    cWhere:="HMN_CODIGO"+GetWhere("=",oDp:cUsdBcv)+" AND "+;
            "HMN_FECHA "+GetWhere("=",oDp:dFecha )

    EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO","HMN_FECHA"  ,"HMN_HORA","HMN_VALOR"},;
                                       {oDp:cUsdBcv ,oDp:dFecha   ,"00:00:00",oDp:nUsdBcv},NIL,.T.,cWhere)

  ENDIF

  /*
  // Euro
  */

  cMemo:=oDp:cMemoUcv
  nAt:=AT("<span> EUR </span>",cMemo)

  IF nAt>0
     cMemo:=SUBS(cMemo,nAt,180)
  ENDIF

  cUsdBcv    :=EJECUTAR("TEXTBETWEEN",cMemo,"<strong>","</strong>")
  cUsdBcv    :=STRTRAN(cUsdBcv,".","")
  cUsdBcv    :=STRTRAN(cUsdBcv,",",".")
  oDp:nEurBcv:=VAL(cUsdBcv)

  EJECUTAR("CREATERECORD","DPTABMON",{"MON_CODIGO","MON_DESCRI"                      ,"MON_ACTIVO","MON_APLICA"},;
                                     {oDp:cEurBcv ,"Euro BCV https://www.bcv.org.ve/",.T.         ,"*"         },NIL,.T.,"MON_CODIGO"+GetWhere("=",oDp:cEurBcv))


  cWhere:="HMN_CODIGO"+GetWhere("=",oDp:cEurBcv  )+" AND "+;
          "HMN_FECHA "+GetWhere("=",oDp:dFechaBcv)

  IF oDp:nEurBcv>0

    EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO","HMN_FECHA"  ,"HMN_HORA","HMN_VALOR"},;
                                       {oDp:cEurBcv ,oDp:dFechaBcv,"00:00:00"   ,oDp:nEurBcv},NIL,.T.,cWhere)

  ENDIF

  oDp:cMemoUcv:="."

  EJECUTAR("DPDOCPROPROGSETVALCA") // Asigna el valor cambiario en calendario fiscal

  /*
  // Lunes Bancario
  */
  dFecha :=SQLGET("DPHISMON","MAX(HMN_FECHA)","HMN_CODIGO"+GetWhere("=",oDp:cUsdBcv  )+" GROUP BY HMN_CODIGO ORDER BY HMN_FECHA LIMIT 1 ")

  // Cotización Publicada el Martes por el BCV cuando el lunes no hay Actividad Bancaria
  cWhere:="HMN_CODIGO"+GetWhere("=",oDp:cUsdBcv  )+" AND HMN_FECHA"+GetWhere("=",oDp:dFecha)

  // 11/09/2023
  IF DOW(dFecha)=3 .AND. DOW(oDp:dFecha)=2 .AND. !ISSQLFIND("DPHISMON",cWhere) .AND. nValor>0

     nValor:=SQLGET("DPHISMON","HMN_VALOR","HMN_CODIGO"+GetWhere("=",oDp:cUsdBcv  )+" AND HMN_FECHA"+GetWhere("=",dFecha))
 
     EJECUTAR("CREATERECORD","DPHISMON",{"HMN_CODIGO","HMN_FECHA"  ,"HMN_HORA","HMN_VALOR"},;
                                         {oDp:cUsdBcv ,oDp:dFecha   ,"00:00:00"   ,nValor     },NIL,.T.,cWhere)
  ENDIF

  oDb:EXECUTE([ UPDATE dphismon SET HMN_HORA="00:00:00" WHERE HMN_HORA="00:00" ])

RETURN oDp:nUsdBcv


FUNCTION TEXTBETWEEN(cText,cOrg,cDes)
   LOCAL nAt

   DEFAULT cText:=[Bs/USD</span>	 </div>   <div class="col-sm-6 col-xs-6"><strong> 20.218,03 </strong> ],;
           cOrg :="<strong>",;
           cDes :="</strong>"

   nAt:=AT(cOrg,cText)

   IF nAt>0
     cText:=SUBS(cText,nAt+LEN(cOrg),LEN(cText))
   ENDIF

   nAt:=AT(cDes,cText)

   IF nAt>0
     cText:=LEFT(cText,nAt-1)
   ENDIF

RETURN cText
// EOF


// EOF
