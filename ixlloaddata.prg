// Programa   : IXLLOADDATA
// Fecha/Hora : 29/04/2023 13:12:57
// Propósito  : Cargar data de los campos y sus definiciones
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cTable,cDescri,cFileIXL,aRef,bPostSave,cRunIxl,cFileXls,cCodigo)
  LOCAL aFields,aSelect
  LOCAL cSelect,I,cCol,cSql,aSort,nAt,lCreate:=.F.,cKey,cForm,cMemo
  LOCAL cNumTab,aData:={},aLine,cField

  DEFAULT  cTable :="DPASIENTOS",;
           aRef   :={},;
           cDescri:="CAMPOS DE LAS TABLAS",;
           cFileXls:=""      

  DEFAULT cCodigo:=SQLGET("DPIMPRXLS","IXL_CODIGO")

  cFileIXL:="FORMS\"+ALLTRIM(cCodigo)+".IXL"
  cMemo   :=ALLTRIM(SQLGET("DPIMPRXLS","IXL_MEMO","IXL_CODIGO"+GetWhere("=",cCodigo)))

  FERASE(cFileIXL)

  IF FILE(cFileIXL)
     MensajeErr("Archivo "+cFileIXL+" posiblemente Abierto por Otra Instancia"+CRLF+"Cierre el Sistema e Ingrese Nuevamente")
     RETURN .F.
  ENDIF

  DPWRITE(cFileIXL,cMemo)

  CursorWait()

  cNumTab:=SQLGET("DPTABLAS","TAB_NUMERO","TAB_NOMBRE"+GetWhere("=",cTable))

  cTable:=ALLTRIM(cTable)

  IF "."$cNumTab // NÀmero del archivo LBX, vino como parametro

    DEFAULT cFileIXL:=cNumTab

    cTable  :=GETINI(cFileIXL,"TABLE") // Lista de Campos ya seleccionados
    cSql    :="SELECT TAB_NUMERO,TAB_DESCRI FROM DPTABLAS WHERE TAB_NOMBRE"+;
               GetWhere("=",cTable)
    oFields :=OpenTable(cSql,.T.)
    cDescri :=oFields:TAB_DESCRI
    cNumTab :=oFields:TAB_NUMERO
    // oFields:End()
  
  ELSE

    // oDp:cPathExe+"FORMS\DEFAULT.LBX"

    DEFAULT cFileIXL:=oDp:cPathExe+"FORMS\"+ALLTRIM(cTable)+".IXL"

  ENDIF

  // Necesito la clave del primer indice de la tabla

//  cForm  :=cFileName(cFileIXL) // Nombre del Formulario
  cSql   :="SELECT CAM_NAME,CAM_DESCRI,CAM_TYPE,CAM_LEN,CAM_DEFAUL,SPACE(1) AS COLXLS FROM DPCAMPOS WHERE CAM_TABLE"+GetWhere("=",cTable)
  aFields:=ASQL(cSql)

  aRef   :=EJECUTAR("IXLLOADREF",cTable,cCodigo)

  IF !Empty(aRef)
     AEVAL(aRef,{|a,n| AADD(aFields,{a[1],a[2],a[3],0,""," "})})
  ENDIF

  aSelect:=EJECUTAR("IXLLOAD",cFileIXL,aFields,cCodigo,cKey)

//  cSelect:=""
//  AEVAL(aSelect,{|a,n|cSelect:=cSelect+IF( Empty(cSelect), "",",")+a[1]  })

  aLine:=ACLONE(aFields[1])
  AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})

  FOR I=1 TO LEN(aSelect)

     cField:=ALLTRIM(aSelect[I,1])
     nAt   :=ASCAN(aFields,{|a,n| ALLTRIM(a[1])=cField})

     IF nAt>0

       aFields[nAt,6]:=aSelect[I,3]

     ELSE

       aLine[1]:=aSelect[I,1]
       aLine[2]:=aSelect[I,2]
       aLine[6]:=aSelect[I,3]

       AADD(aFields,ACLONE(aLine))

     ENDIF

  NEXT I

  // ViewArray(aFields)
  // Copiamos los primeros que tienen Datos
  aData:=ACLONE(aFields)
  ADEPURA(aData  ,{|a,n| Empty(a[6])})
  ADEPURA(aFields,{|a,n|!Empty(a[6])})

  aData:=ASORT(aData,,, { |x, y| x[6] < y[6] })

  AEVAL(aFields,{|a,n| AADD(aData,a)})

RETURN aData
// EOF
