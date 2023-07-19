// Programa   : IMPCLIENTECSV
// Fecha/Hora : 07/07/2023 23:58:12
// Propósito  : Importar Clientes 
// Datos      : https://github.com/AdaptaProERP/dpxbase_diccionario_de_datos/blob/main/CLIENTES.CSV
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lInicio)
  LOCAL cFile:="c:\nadjul\clientes.csv"
  LOCAL cMemo,I,cCodigo,cNombre,cCodVen,cCodCla
  LOCAL cSql,cLista,cRif,cCodAct:="0000",cTipPer
  LOCAL nContar:=0
  LOCAL oTable,oDb:=OpenOdbc(oDp:cDsnData),oTableV,oTableC,oTableA
  LOCAL aData:={},aLine,aDir

  DEFAULT lInicio:=.T.

  IF !FILE(cFile)
     MsgMemo(cFile,"No existe")
     RETURN .F.
  ENDIF 
  
  cSql   :=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

  IF lInicio
    SQLDELETE("DPCLIENTES")
    SQLDELETE("DPCLICLA")
    SQLDELETE("DPACTIVIDAD_E")
    SQLDELETE("DPVENDEDOR")
  ENDIF

/*
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_OBS1"   ,250)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_OBS2"   ,250)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_NOMBRE" ,120)

  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_DIR1"   ,120)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_DIR2"   ,120)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_DIR3"   ,120)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_DIR4"   ,120)
*/

  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_TEL1"   ,20)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_TEL2"   ,20)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_TEL3"   ,20)
  EJECUTAR("SETFIELDLONG","DPCLIENTES" ,"CLI_TEL4"   ,20)

  EJECUTAR("CREATERECORD","DPCLICLA",{"CLC_CODIGO","CLC_DESCRI","CLC_ACTIVO" },;
                                     {cCodAct   ,"Indefinido",.T.          },;
                                     NIL,.T.,"CLC_CODIGO"+GetWhere("=",cCodAct))

  cMemo:=MEMOREAD(cFile)
  cMemo:=STRTRAN(cMemo,CHR(10),"")
  cMemo:=STRTRAN(cMemo,["],[])
//  cMemo:=STRTRAN(cMemo,CRLF,CHR(10))
  aData:=_VECTOR(cMemo,CHR(13))

  FOR I=1 TO LEN(aData)
     aData[I]:=_VECTOR(aData[I],";")
     aData[I]:=ASIZE(aData[I],13)
  NEXT I

  ADEPURA(aData,{|a,n| LEN(a)>13 .OR. Empty(a[3])})

  cCodCla:=SQLGETMIN("DPCLICLA","CLC_CODIGO")

  oTableV:=OpenTable("SELECT * FROM DPVENDEDOR"   ,.F.)
  oTableC:=OpenTable("SELECT * FROM DPCLICLA"     ,.F.)
  oTableA:=OpenTable("SELECT * FROM DPACTIVIDAD_E",.F.)


  oTable :=OpenTable("SELECT * FROM DPCLIENTES"    ,.F.)
  oTable:SetInsert(1)
  nContar:=2

  WHILE nContar<=LEN(aData)
    
     IF nContar%20=0
       oDp:oFrameDp:SetText(LSTR(nContar)+"/"+LSTR(LEN(aData)))
     ENDIF

     aLine   :=aData[nContar]
     cRif    :=STRTRAN(aLine[3],"-","")
     cRif    :=STRTRAN(aLine[3]," ","")
     cRif    :=LEFT(STRTRAN(cRif,"VV","V"),10)
     cTipPer :=LEFT(cRif,1)
     cTipPer :=IF(cTipPer="V","N",cTipPer)
     cTipPer :=IF(cTipPer="E","N",cTipPer)
     cCodigo :=LEFT(aLine[1],10)
     cCodigo :=STRTRAN(cCodigo,"-","")
     cCodigo :=STRTRAN(cCodigo," ","")
     cNombre :=aLine[2]
     cCodVen :=BUILVENDEDOR(aLine[5])
//     cCodCla :=BUILDCODCLA(aLine[10])
     cCodAct :=BUILDCODACT(aLine[10])
     aDir    :=EJECUTAR("BUILDARRAYDIR",aLine[12])

     cLista  :="A"

     IF "Minimo"$aLine[8]
       cLista:="D"
     ENDIF

     aLine[10]:=STRTRAN(aLine[10],["],[])
     aLine[10]:=STRTRAN(aLine[10],[`],[])
     aLine[10]:=STRTRAN(aLine[10],['],[])

     aLine[12]:=STRTRAN(aLine[12],["],[])
     aLine[12]:=STRTRAN(aLine[12],[`],[])
     aLine[12]:=STRTRAN(aLine[12],['],[])

     oTable:AppendBlank()
     oTable:ReplaceSpeed("CLI_CODIGO",cCodigo )
     oTable:ReplaceSpeed("CLI_NOMBRE",LEFT(cNombre,120))
     oTable:ReplaceSpeed("CLI_TIPPER",cTipPer )
     oTable:ReplaceSpeed("CLI_TEL1"  ,LEFT(aLine[4],20))
     oTable:ReplaceSpeed("CLI_RIF"   ,cRif     )
     oTable:ReplaceSpeed("CLI_OBS1"  ,aLine[10])
     oTable:ReplaceSpeed("CLI_EMAIL" ,aLine[13])
     oTable:ReplaceSpeed("CLI_CODCLA",cCodCla)
     oTable:ReplaceSpeed("CLI_CODVEN",cCodVen)
     oTable:ReplaceSpeed("CLI_ACTIVI",cCodAct)
     oTable:ReplaceSpeed("CLI_ENOTRA","S")

     oTable:ReplaceSpeed("CLI_DIR1",aDir[1])
     oTable:ReplaceSpeed("CLI_DIR2",aDir[2])
     oTable:ReplaceSpeed("CLI_DIR3",aDir[3])
     oTable:ReplaceSpeed("CLI_DIR4",aDir[4])

     oTable:ReplaceSpeed("CLI_CODMON",oDp:cMonedaExt)
     oTable:ReplaceSpeed("CLI_DIAS"  ,CTOO(aLine[7],"N"))
     oTable:ReplaceSpeed("CLI_LISTA" ,cLista)
     oTable:ReplaceSpeed("CLI_SITUAC","Activo")

     oTable:CommitSpeed(.F.)

     // oTable:lAuditar:=.F.
     // oTable:Commit(NIL,.F.)

     IF nContar%20=0
       SysRefresh(.T.)
     ENDIF

     nContar++

  ENDDO

  oTable:End()
  oTableV:End()
  oTableC:End()
  oTableA:End()

  ? "Importación concluida"

  cSql   :=" SET FOREIGN_KEY_CHECKS = 1"

  oDb:Execute(cSql)

RETURN NIL


/*
// Obtiene el Grupo
*/
FUNCTION BUILVENDEDOR(cNombre)
  LOCAL oTable

  cCodVen:=SQLGET("DPVENDEDOR","VEN_CODIGO","VEN_NOMBRE"+GetWhere("=",cNombre))

  IF !Empty(cCodVen)
     RETURN cCodVen
  ENDIF
  
  cCodVen:=SQLINCREMENTAL("DPVENDEDOR","VEN_CODIGO",NIL,NIL,NIL,.T.,4)

  // oTable:=OpenTable("SELECT * FROM DPVENDEDOR",.F.)
  oTableV:Append()
  oTableV:lAuditar:=.F.
  oTableV:Replace("VEN_CODIGO",cCodVen)
  oTableV:Replace("VEN_NOMBRE",cNombre)
  oTableV:Replace("VEN_SITUAC","Activo")
  oTableV:Commit(NIL,.F.)

// ? cCodVen,cNombre,CLPCOPY(oDp:cSql)

RETURN cCodVen


/*
// Obtiene el Grupo
*/
FUNCTION BUILDCODCLA(cNombre)
  LOCAL oTable,cCodCla

  cCodCla:=SQLGET("DPCLICLA","CLC_CODIGO","CLC_DESCRI"+GetWhere("=",cNombre))

  IF !Empty(cCodCla)
     RETURN cCodCla
  ENDIF
  
  cCodCla:=SQLINCREMENTAL("DPCLICLA","CLC_CODIGO",NIL,NIL,NIL,.T.,4)

  //oTable:=OpenTable("SELECT * FROM DPCLICLA",.F.)
  oTableC:Append()
  oTableC:lAuditar:=.F.
  oTableC:Replace("CLC_CODIGO",cCodCla)
  oTableC:Replace("CLC_DESCRI",cNombre)
  oTableC:Replace("CLC_ACTIVO",.T.    )
  oTableC:Commit(NIL,.F.)
  // oTable:End()

RETURN cCodCla


FUNCTION BUILDCODACT(cNombre)
  LOCAL cCodAct

  cCodAct:=SQLGET("DPACTIVIDAD_E","ACT_CODIGO","ACT_DESCRI"+GetWhere("=",cNombre))

  IF !Empty(cCodAct)
     RETURN cCodAct
  ENDIF
  
  cCodAct:=SQLINCREMENTAL("DPACTIVIDAD_E","ACT_CODIGO",NIL,NIL,NIL,.T.,4)

  // oTable:=OpenTable("SELECT * FROM DPACTIVIDAD_E",.F.)
  oTableA:Append()
  oTableA:lAuditar:=.F.
  oTableA:Replace("ACT_CODIGO",cCodAct)
  oTableA:Replace("ACT_DESCRI",cNombre)
  oTableA:Replace("ACT_ACTIVO",.T.    )
  oTableA:Commit(NIL,.F.)
  // oTable:End()

RETURN cCodAct
// EOF


// EOF



