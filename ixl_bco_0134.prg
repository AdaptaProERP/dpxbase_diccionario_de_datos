/*
// Importación de datos desde excel
// Tabla  <TABLA>
// Código BCO_0134
// Fecha  08/04/2024
//
*/

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,oMeter,oSay,oMemo)
    LOCAL cFileDbf,cFileXls,cTable,cCodigo,cWhere
    LOCAL oTable,oXls
    LOCAL nLinIni,nContar,I,U

    DEFAULT cCodigo:="BCO_0134"

    IF Empty(oParXls:cCodBco) .AND. !EJECUTAR("DPREGLEEEDOCTAVALID",cCodigo,oMemo)
       RETURN .F.
    ENDIF

    IF(ValType(oMemo)="O",oMemo:Append("Cuenta "+oParXls:cCtaBanco +CRLF),NIL)
    IF(ValType(oMemo)="O",oMemo:Append("Cuenta "+oParXls:cBcoNombre+CRLF),NIL)


    oTable  :=OpenTable("SELECT IXL_FILE,IXL_TABLA,IXL_LININI FROM DPIMPRXLS WHERE IXL_CODIGO"+GetWhere("=",cCodigo),.T.)
    cFileXls:=ALLTRIM(oTable:IXL_FILE  )
    cTable  :=ALLTRIM(oTable:IXL_TABLA )
    nLinIni :=MAX(oTable:IXL_LININI,1)
    oTable:End(.T.)

    IF COUNT(cTable)>0 .AND. MsgYesNo("Desea Remover todos los Registros de la tabla "+cTable)
      SQLDELETE(cTable)
    ENDIF

    IF(ValType(oSay)="O",oSay:SetText("Creando Registro"),NIL)

    EJECUTAR("DPREGLEEEDOCTACREA",cFileXls)

    IF(ValType(oSay)="O",oSay:SetText("Registro "+oParXls:cNumero),NIL)
    IF(ValType(oSay)="O",oSay:SetText("Leyendo Archivo"),NIL)

    // Parámetros Bancarios
    oParXls:cCodBco  
    oParXls:cCtaBanco
    oParXls:cCodIBP  
    oParXls:cNumero  

    cWhere :="RLE_CODBCO"+GetWhere("=",oParXls:cCodBco)+" AND "+;
             "RLE_CUENTA"+GetWhere("=",oParXls:cCodCta)+" AND "+;
             "RLE_NUMERO"+GetWhere("=",oParXls:cNumero)

    oParXls:cNumero:=SQLINCREMENTAL("DPREGLEEEDOCTA","RLE_NUMERO",cWhere)

    oXls:=EJECUTAR("XLSTORDD",cFileXls,NIL,oMeter,oSay,NIL,nLinIni)

ViewArray(oXls:aData)
// oXls:Browse()

RETURN 
    IF(ValType(oMeter)="O",oMeter:SetTotal(oXls:RecCount()),NIL)

    oTable:=OpenTable("SELECT * FROM "+cTable, .F. )
    oTable:lAuditar:=.F.
    oTable:SetForeignkeyOff()

    oXls:Gotop()

   WHILE !oXls:Eof()

      IF(ValType(oSay  )="O",oSay:SetText("Reg:"+GetNumRel(oXls:Recno(),oXls:RecCount())),NIL)
      IF(ValType(oMeter)="O",oMeter:Set(oXls:Recno()),NIL)

      cCodigo:=STRTRAN(ALLTRIM(oXls:COL_A),"-","")
      cCodigo:=STRTRAN(cCodigo,";","")
      cCodigo:=STRTRAN(cCodigo,"/","")

      IF Empty(cCodigo)
         oXls:DbSkip()
         LOOP
      ENDIF

      IF(ValType(oMemo)="O",oMemo:Append("#"+LSTR(oXls:Recno())+"->"+cCodigo+CRLF),NIL)

      cWhere    :="FIELD"+GetWhere("=",cCodigo)

      IF !ISSQLFIND(cTable,cWhere)
        oTable:AppendBlank()
        oTable:Replace("FIELD",cCodigo)
        oTable:Commit("")
      ENDIF

      oXls:DbSkip()

   ENDDO

   IF(ValType(oMeter)="O",oMeter:Set(oXls:RecCount()),NIL)
   IF(ValType(oMemo )="O",oMemo:Append("Importación Concluida"+CRLF),NIL)

   oTable:End(.T.)
   oXls:End()

RETURN .T.
