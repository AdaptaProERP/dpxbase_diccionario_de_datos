// Programa   : SERCOMIMPINV
// Fecha/Hora : 09/05/2023 09:04:58
// Propósito  : Importar Archivo PRODUCTOS.CSV Obtenido desde PRODUCTOS.XLSX
// Creado Por : Juan Navas
// Llamado por: Desde Programación
// Aplicación : Programación
// Tabla      : DPINV,DPGRU,DPPRECIOS 
// Descargar  : https://mega.nz/file/5UV3gLDI#1Iu0hHTneHS6ke5OBQbbmJDzr2vJeiIYtmGhwunlrl8

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cFile:="c:\sercon\productosconexistencia.CSV"
  LOCAL cMemo:=MemoRead(cFile),aData,I,aLine,cWhere,cGrupo,nCostoD,nValCam,nMesGar:=0,cObs1:="",nExiste:=0,nCosto:=0

  IF !FILE(cFile)
     MsgMemo("Archivo "+cFile+" no Encontrado")
     RETURN .F.
  ENDIF

  cMemo:=STRTRAN(cMemo,CRLF,CHR(10)) // Reemplazar CHR(13)+CHR(10)


  aData:=_VECTOR(cMemo,CHR(10))      // Crear Arreglo desde Memo separados por CHR(10)

  AEVAL(aData,{|a,n| aData[n]:=_VECTOR(a,";")})       // Convierte cada Linea en Multilinea separados por ;

  aData:=ADEPURA(aData,{|a,n| Empty(a[1]) })          // Remueve lineas Vacias

// viewArray(aData)
// return 

  FOR I=1 TO LEN(aData)

      aLine:=aData[I]

      cGrupo :=SQLGET("DPINV","INV_GRUPO,INV_OBS1,INV_MESGAR","INV_CODIGO"+GetWhere("=",aLine[1]))
      cObs1  :=DPSQLROW(2)
      nMesGar:=DPSQLROW(3)

      IF Empty(cGrupo)
         cGrupo:="INDEF"
         cGrupo:=BUILDGRUPO(cGrupo)
      ENDIF

      EJECUTAR("CREATERECORD","DPINV",{"INV_CODIGO","INV_DESCRI","INV_ESTADO","INV_GRUPO","INV_IVA","INV_OBS1","INV_MESGAR"  },; 
                                      {aLine[1]    ,aLine[2]    ,"A"         ,cGrupo      ,"GN"    ,cObs1      ,nMesGar      },;
                                      NIL,.T.,"INV_CODIGO"+GetWhere("=",aLine[1]))
     
      aLine[4]:=STRTRAN(aLine[4],"$","") // Costo
      aLine[5]:=STRTRAN(aLine[5],"$","") // Precio Mayor
      aLine[6]:=STRTRAN(aLine[6],"$","") // Precio Detal
      aLine[7]:=STRTRAN(aLine[7],"$","") // Precio Promocion
      aLine[6]:=STRTRAN(aLine[8],"$","") // Precio Detal
      aLine[7]:=STRTRAN(aLine[9],"$","") // Precio Promocion

      aLine[4]:=VAL(STRTRAN(aLine[4],",",".")) // D->Costo Estandar
      aLine[5]:=VAL(STRTRAN(aLine[5],",",".")) // E->Costo Advance
      aLine[6]:=VAL(STRTRAN(aLine[6],",",".")) // F->Precio venta
      aLine[7]:=VAL(STRTRAN(aLine[7],",",".")) // G->Precio Mayor 
      aLine[8]:=VAL(STRTRAN(aLine[8],",",".")) // H->Total
      aLine[9]:=VAL(STRTRAN(aLine[9],",",".")) // I->Precio Inauguración

      EJECUTAR("DPINVCREAUND",  aLine[1],"UND") 
      EJECUTAR("DPPRECIOSCREAR",aLine[1],"A","UND","DBC",aLine[6]) // Venta
      EJECUTAR("DPPRECIOSCREAR",aLine[1],"B","UND","DBC",aLine[7]) // Mayor
      EJECUTAR("DPPRECIOSCREAR",aLine[1],"C","UND","DBC",aLine[9])


      nExiste:=aLine[3]
      nCosto :=aLine[4]
      // Existencia Inicial
      EJECUTAR("DPINVEXIINI",aLine[1],nExiste,nCosto*nValCam,"UND",1,aLine[4])

// ? oDp:cSql,aLine[1]

//    IF I>2
//      EXIT
//    ENDIF

   NEXT I

RETURN .T.
// EOF

/*
// Obtiene el Grupo
*/
FUNCTION BUILDGRUPO(cGrupo)
  LOCAL oTable,cCodigo

  IF Empty(cGrupo)
     cGrupo:=STRZERO(0,6)
  ENDIF

  cCodigo:=SQLGET("DPGRU","GRU_CODIGO","GRU_DESCRI"+GetWhere("=",cGrupo))
  
  IF !Empty(cCodigo)
      RETURN cCodigo
  ENDIF

  cCodigo:=SQLINCREMENTAL("DPGRU","GRU_CODIGO")
  
  oTable:=OpenTable("SELECT * FROM DPGRU",.F.)
  oTable:Append()
  oTable:Replace("GRU_CODIGO",cCodigo)
  oTable:Replace("GRU_DESCRI",cGrupo )
  oTable:Replace("GRU_ACTIVO",.T.    )
  oTable:Commit(NIL,.F.)
  oTable:End()

RETURN cCodigo
// EOF


