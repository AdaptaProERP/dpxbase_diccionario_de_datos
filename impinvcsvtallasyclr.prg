// Programa   : IMPINVCSVTALLASYCLR
// Fecha/Hora : 07/07/2023 23:58:12
// Propósito  : Importar Producto con Tallas y Colores
// Datos      : https://github.com/AdaptaProERP/dpxbase_diccionario_de_datos/blob/main/productosparalaventacon_tallas_y_colores.csv
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lInicio)
  LOCAL cFile:="ejemplo\productosparalaventacon_tallas_y_colores.csv"
  LOCAL cMemo,I,U,cCodigo,cDescri,cColor,cCodGru,cCodMar,cCodClr,cCodDep,cRefere,cColor,cIdTalla
  LOCAL cTalla :="",cCodOld:="",cSql,cLista,cItem,cField,cUnd
  LOCAL cCodAnt:="",nContar:=0
  LOCAL oTable,oPrecio,oDb:=OpenOdbc(oDp:cDsnData),oMovInv
  LOCAL aData:={},aPrecio:={},aLine,aTallas:={},aCosto:={},aData11:={},aLista:={}
  LOCAL nCant,nCosto,nPrecioA,nPrecioB,nPrecioD,nPrecioC

  DEFAULT lInicio:=.T.
  
  AADD(aPrecio,{"A","Máximo"})
  AADD(aPrecio,{"B","Oferta"})
  AADD(aPrecio,{"C","Mayor" })
  AADD(aPrecio,{"D","Mínimo"})

  IF lInicio
      SQLDELETE("DPIVATIP")
      SQLDELETE("DPPRECIOTIP")
      SQLDELETE("DPMOVINV","MOV_APLORG"+GetWhere("=", "I"))
      SQLDELETE("DPPRECIOS")
      SQLDELETE("DPINVMED")
      SQLDELETE("DPEQUIV")
      SQLDELETE("DPCOMPONENTES")
      SQLDELETE("DPINV")
      SQLDELETE("DPGRU")
      SQLDELETE("DPMARCAS")
      SQLDELETE("DPTALLAS")
  ENDIF

  EJECUTAR("CREATERECORD","DPUNDMED",{"UND_CODIGO","UND_DESCRI","UND_ACTIVO","UND_CANUND" },;
                                     {"PAR"       ,"PAR"       ,.T.         ,1          },;
                                     NIL,.T.,"UND_CODIGO"+GetWhere("=","PAR"))

  oTable:=OpenTable("SELECT * FROM DPPRECIOTIP",.F.)

  FOR I=1 TO LEN(aPrecio)

    cLista :=aPrecio[I,1]
    cDescri:=aPrecio[I,2]

    oTable:AppendBlank()
    oTable:Replace("TPP_CODIGO",aPrecio[I,1])
    oTable:Replace("TPP_DESCRI",aPrecio[I,2])
    oTable:Replace("TPP_CODMON","DBC")
    oTable:Replace("TPP_DINAMI",.T.) 
    oTable:Replace("TPP_ACTIVO",.T.)
    oTable:lAuditar:=.F.
    oTable:Commit()

  NEXT I

  oTable:End()

  IF !FILE(cFile)
     MsgMemo(cFile,"No existe")
     RETURN .F.
  ENDIF 

  cMemo:=MEMOREAD(cFile)

  cMemo:=STRTRAN(cMemo,CRLF,CHR(10))
  aData:=_VECTOR(cMemo,CHR(10))

  FOR I=1 TO LEN(aData)
     aData[I]:=_VECTOR(aData[I],";")
     IF LEN(aData[I])=11
       AADD(aData11,aData[I])
       aData[I]:=ASIZE(aData[I],12)
     ENDIF
  NEXT I

  ADEPURA(aData,{|a,n| ALLTRIM(a[1])="Codigo"})

  cCodigo:=aData[1,1]

  FOR I=1 TO LEN(aData)

    IF Empty(aData[I,1])
       aData[I,1]:=cCodigo
    ELSE
       cCodigo:=aData[I,1]
    ENDIF

  NEXT

  cCodDep:=SQLGET("DPDPTO","DEP_CODIGO")                  
  cSql    :=" SET FOREIGN_KEY_CHECKS = 0"

  oDb:Execute(cSql)

  oPrecio:=OpenTable("SELECT * FROM DPPRECIOS",.F.)
  oTable :=OpenTable("SELECT * FROM DPINV"    ,.F.)
  oMovInv:=OpenTable("SELECT * FROM DPMOVINV" ,.F.)

  nContar:=1

  WHILE nContar<=LEN(aData)
    
     oDp:oFrameDp:SetText(LSTR(nContar)+"/"+LSTR(LEN(aData)))

     aLine   :=aData[nContar]
     cCodigo :=aLine[1]
     cDescri :=aLine[2]
     cCodGru :=BUILDGRUPO(aLine[5],"Fabricación")
     cCodMar :=BUILDMARCA(aLine[7])
     cColor  :=aLine[3]

     nCosto  :=CTOO(aLine[08],"N")
     nPrecioA:=CTOO(aLine[09],"N")
     nPrecioB:=CTOO(aLine[10],"N")
     nPrecioD:=CTOO(aLine[11],"N")
     nPrecioC:=CTOO(aLine[12],"N")
     cRefere :=aLine[6]
     aCosto  :={}
     aTallas :={}
     cUnd    :="PAR"
     
     WHILE nContar<=LEN(aData) .AND. aData[nContar,1]==cCodigo

       oDp:oFrameDp:SetText(LSTR(nContar)+"/"+LSTR(LEN(aData)))

       aLine  :=aData[nContar]

       IF !Empty(aLine[3])
         cColor :=aLine[3]
       ENDIF

       AADD(aTallas,aLine[4])
      
       IF !Empty(aLine[3])
          cCodClr:=BUILDCOLOR(aLine[3])
       ENDIF

       AADD(aCosto,{cCodClr,aLine[4],aLine[8],aLine[9],aLine[10],aLine[11],aLine[12]})

       nContar++

     ENDDO

     IF "GL64400"$cCodigo
        // ViewArray(aCosto,cCodigo) 
        // RETURN 
     ENDIF

     IF "S/M  Y  L/XL"$aLine[4]
        aTallas:={"S","M","L","XL"}
        cTalla :=BUILDTALLAS(aTallas,aLine[4])
        aTallas:={}
     ENDIF                           

     IF "AJUS"$UPPER(aLine[4])
        aTallas:={}
        cTalla :=BUILDTALLAS({"AJS"},"Ajustable")
        cUnd   :=oDp:cUndMed  
     ENDIF

     IF !Empty(aTallas)
       cTalla :=BUILDTALLAS(aTallas,NIL)
     ENDIF

// ViewArray(aTallas)
// ? cTalla,"cTalla"

     IF !ISSQLFIND("DPINV","INV_CODIGO"+GetWhere("=",cCodigo))

       oTable:AppendBlank()

       oTable:Replace("INV_IVA"   ,"GN"   )
       oTable:Replace("INV_CODIGO",cCodigo)
       oTable:Replace("INV_DESCRI",cDescri)
       oTable:Replace("INV_GRUPO" ,cCodGru)
       oTable:Replace("INV_CODDEP",cCodDep)
       oTable:Replace("INV_ESTADO","A"    ) 
       oTable:Replace("INV_CODMAR",cCodMar)
       oTable:Replace("INV_TALLAS",cTalla )
       oTable:Replace("INV_COSFOB",nCosto )

       oTable:Replace("INV_UTILIZ","V")
       oTable:Replace("INV_APLICA","T")
       oTable:Replace("INV_PROCED","N")
       oTable:Replace("INV_METCOS","P")
       oTable:Replace("INV_OBS1"  ,cRefere)
       oTable:Replace("INV_COLOR" ,cColor)


//     oTable:Replace("INV_EXIMIN",DPINV->EXMIN)
//     oTable:Replace("INV_EXIMAX",DPINV->EXMAX)
       oTable:Replace("INV_COSFOB",nCosto)
//     oTable:Replace("INV_COSUND",DPINV->COSTO_ACT)

       oTable:Replace("INV_FCHCRE",oDp:dFecha)
       oTable:Replace("INV_FCHACT",oDp:dFecha)

       oTable:lAuditar:=.F.
       oTable:Commit(NIL,.F.)

     ENDIF

     aPrecio:={nPrecioA,nPrecioB,nPrecioD,nPrecioC}
     aLista :={"A"     ,"B"     ,"C"     ,"D"     }

     oDp:oFrameDp:SetText(LSTR(nContar)+"/"+LSTR(LEN(aData))+" talla ->"+cTalla)


     FOR I=1 TO LEN(aPrecio)

       oPrecio:Append()
       oPrecio:Replace("PRE_CODIGO",oTable:INV_CODIGO)
       oPrecio:Replace("PRE_UNDMED",cUnd           )
       oPrecio:Replace("PRE_LISTA" ,aLista[I]      )
       oPrecio:Replace("PRE_PRECIO",aPrecio[I]     )
       oPrecio:Replace("PRE_CODMON",oDp:cMonedaExt )
       oPrecio:Replace("PRE_FECHA" ,oDp:dFecha     )
       oPrecio:Replace("PRE_HORA"  ,TIME()         )
       oPrecio:Replace("PRE_USUARI",oDp:cUsuario   )
       oPrecio:Replace("PRE_ORIGEN","INV"          )
       oPrecio:Replace("PRE_IP"    ,GETHOSTBYNAME())
       oPrecio:Replace("PRE_FECHAV",CTOD("")       )

       oPrecio:lAuditar:=.F.
       oPrecio:Commit("")
      
     NEXT I

     EJECUTAR("DPINVCREAUND",oTable:INV_CODIGO,cUnd) // oDp:cUndMed)

     FOR I=1 TO LEN(aCosto)

      // AADD(aCosto,{cCodClr,aLine[4],aLine[8],aLine[9],aLine[10],aLine[11],aLine[12]})
      // Por Cada Talla debe ubicar su 

      aLine   :=aCosto[I]

// ViewArray(aLine)

      nCant   :=MAX(LEN(aTallas),1)
      cItem   :=STRZERO(I,5) 
      cColor  :=aLine[1]
      cIdTalla:=aLine[2] // Numero de la talla
      nCosto  :=CTOO(aLine[3],"N")  // Costo
      cField  :=""

      IF !Empty(cIdTalla)
         cField  :=EJECUTAR("DPTALLASGETCOL",cTalla,cIdTalla)
      ENDIF

      oMovInv:Replace("MOV_FECHA"  , oDp:dFecha    )
      oMovInv:Replace("MOV_HORA"   , TIME()        )
      oMovInv:Replace("MOV_ITEM"   , cItem         )
      oMovInv:Replace("MOV_APLORG" , "I"           )
      oMovInv:Replace("MOV_TIPDOC" , "INI"         )
      oMovInv:Replace("MOV_DOCUME" , "INICIO"      )
      oMovInv:Replace("MOV_CODTRA" , "E000")
      oMovInv:Replace("MOV_CODALM" , oDp:cAlmacen  )
      oMovInv:Replace("MOV_CODSUC" , oDp:cSucursal )
      oMovInv:Replace("MOV_CODIGO" , cCodigo       )
      oMovInv:Replace("MOV_LOGICO" , 1)
      oMovInv:Replace("MOV_CONTAB" , 1)
      oMovInv:Replace("MOV_FISICO" , 1)
      oMovInv:Replace("MOV_CXUND"  , 1)
      oMovInv:Replace("MOV_TIPO"   , "I"           )
      oMovInv:Replace("MOV_UNDMED" , oDp:cUndMed   )
      oMovInv:Replace("MOV_USUARI" , oDp:cUsuario  )
      oMovInv:Replace("MOV_COSTO"  , nCosto        )
//    oMovInv:Replace("MOV_PRECIO" , nPrecio       )
//    oMovInv:Replace("MOV_TOTAL"  , nPrecio*nCant )
//    oMovInv:Replace("MOV_MTODIV" , nPrecioD      )
      oMovInv:Replace("MOV_CANTID" , ABS(nCant)    )
      oMovInv:Replace("MOV_INVACT" , 1             )
      oMovInv:Replace("MOV_LOTE"   , cColor        )
      oMovInv:Replace("MOV_ITEM_C" , cIdTalla      )

      IF !Empty(cField)
        nCant:=1
        oMovInv:Replace(cField, nCant)
      ENDIF

      oMovInv:lAuditar:=.F.
      oMovInv:Commit("")


     NEXT I

     SysRefresh(.T.)

// EXIT

  ENDDO

  oPrecio:End()
  oTable:End()

  ? "Importación concluida"

// ViewArray(aData)

RETURN

/*
// Obtiene el Grupo
*/
FUNCTION BUILDGRUPO(cGrupo,cUtiliz)
  LOCAL oTable,cCodGru

  cCodGru:=SQLGET("DPGRU","GRU_CODIGO","GRU_DESCRI"+GetWhere("=",cGrupo))

  IF !Empty(cCodGru)
     RETURN cCodGru
  ENDIF
  
  cCodGru:=SQLINCREMENTAL("DPGRU","GRU_CODIGO",NIL,NIL,NIL,.T.,4)

  oTable:=OpenTable("SELECT * FROM DPGRU",.F.)
  oTable:Append()
  oTable:lAuditar:=.F.
  oTable:Replace("GRU_CODIGO",cCodGru)
  oTable:Replace("GRU_DESCRI",cGrupo )
  oTable:Replace("GRU_UTILIZ",cUtiliz)
  oTable:Replace("GRU_ACTIVO",.T.    )
  oTable:Commit(NIL,.F.)
  oTable:End()

RETURN cCodGru


/*
// Obtiene el Grupo
*/
FUNCTION BUILDMARCA(cMarca)
  LOCAL oTable,cCodMar

  cCodMar:=SQLGET("DPMARCAS","MAR_CODIGO","MAR_DESCRI"+GetWhere("=",cMarca))

  IF !Empty(cCodMar)
     RETURN cCodMar
  ENDIF
  
  cCodMar:=SQLINCREMENTAL("DPMARCAS","MAR_CODIGO",NIL,NIL,NIL,.T.,4)

  oTable:=OpenTable("SELECT * FROM DPMARCAS",.F.)
  oTable:Append()
  oTable:lAuditar:=.F.
  oTable:Replace("MAR_CODIGO",cCodMar)
  oTable:Replace("MAR_DESCRI",cMarca )
  oTable:Replace("MAR_ACTIVO",.T.    )
  oTable:Commit(NIL,.F.)
  oTable:End()

RETURN cCodMar

/*
// Obtiene el Grupo
*/
FUNCTION BUILDCOLOR(cColor)
  LOCAL oTable

  IF !Empty(SQLGET("DPCOLORES","COL_CODIGO","COL_CODIGO"+GetWhere("=",cColor)))
     RETURN cColor
  ENDIF
  
  oTable:=OpenTable("SELECT * FROM DPCOLORES",.F.)
  oTable:Append()
  oTable:lAuditar:=.F.
  oTable:Replace("COL_CODIGO",cColor)
  oTable:Replace("COL_ACTIVO",.T.    )
  oTable:Commit(NIL,.F.)
  oTable:End()

RETURN cColor

FUNCTION BUILDTALLAS(aTallas,cDescri)
  LOCAL I,cWhere:="",cField,cMin:="",cMax:=""
  LOCAL oTable,cTalla
  
  ADEPURA(aTallas,{|a,n| Empty(a)})

  IF Empty(aTallas)
    RETURN ""
  ENDIF

  IF LEN(aTallas)=1 .AND. "S/M  Y  L/XL"$aTallas[1]
     aTallas:={"S","M","L","XL"}
  ENDIF

  IF LEN(aTallas)=1 .AND. "AJUS"$aTallas[1]
     aTallas:={"AJS"}
  ENDIF

  // ASORT(aTallas)
  cMin:=aTallas[1]
 
  FOR I=1 TO LEN(aTallas)
     // cMax  :=IF(aTallas[I]>cMax,aTallas[I],cMax)
     // cMax  :=MAXCHAR(cMax,aTallas[I])
     cWhere:=cWhere+ IF(Empty(cWhere),""," AND ")+"TAL_"+STRZERO(I,2)+GetWhere("=",aTallas[I])
  NEXT I

  cMax   :=ATAIL(aTallas)
  cDescri:=IF(Empty(cDescri),cMin+"-"+cMax,cDescri)
  cDescri:=UPPER(cDescri)
  cTalla :=SQLGET("DPTALLAS","TAL_CODIGO","TAL_DESCRI"+GetWhere("=",cDescri))

  IF !Empty(cTalla)
     RETURN cTalla
  ENDIF

  cTalla :=SQLGET("DPTALLAS","TAL_CODIGO",cWhere)

  IF !Empty(cTalla)
     RETURN cTalla
  ENDIF

  cTalla:=SQLINCREMENTAL("DPTALLAS","TAL_CODIGO",NIL,NIL,NIL,.T.,4)
  oTable:=OpenTable("SELECT * FROM DPTALLAS",.F.)
  oTable:Append()
  oTable:lAuditar:=.F.
  oTable:Replace("TAL_CODIGO",cTalla )
  oTable:Replace("TAL_DESCRI",cDescri)

  FOR I=1 TO LEN(aTallas)
     cField:="TAL_"+STRZERO(I,2)
     oTable:Replace(cField,aTallas[I])
  NEXT I

  oTable:Replace("TAL_ACTIVO",.T.    )
  oTable:Commit(NIL,.F.)
  oTable:End()

  oDp:aTallas:={}

RETURN cTalla
// EOF


