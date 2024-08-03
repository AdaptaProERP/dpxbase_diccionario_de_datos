// Programa   : DPCHANGECOD
// Fecha/Hora : 05/05/2004
// Propósito  : Union de Datos de dos Registros
// Creado Por : Juan Navas
// Llamado por: Menú Principal
// Aplicación : Todas 
// Tabla      : Todas       

#INCLUDE "DPXBASE.CH"

PROCEDURE DPCHANGECOD(cTable,cField,cDescri,uValue,cTitle,cWhere)
  LOCAL nLen
  LOCAL cFieldDesc:="" // Nombre del Campo DESCRI
  LOCAL cFieldName:="" // Nombre del Campo CODIGO
  LOCAL oTable

  DEFAULT cWhere:=""

  IF cTable=NIL
    cTable :="DPGRU"
    cField :="GRU_CODIGO"
    uValue :=SPACE(8)
    cTitle :="Unir Grupos"
    cDescri:="GRU_DESCRI"
  ENDIF

  DEFAULT cTitle:="Unir Registros"

  oTable:=OpenTable("SELECT CAM_DESCRI FROM DPCAMPOS WHERE CAM_TABLE"+GetWhere("=",cTable)+;
                    " AND CAM_NAME"+GetWhere("=",cDescri),.T.)
  cFieldDesc:=oTable:FieldGet(1)
  oTable:End()

  oTable:=OpenTable("SELECT CAM_DESCRI,CAM_LEN FROM DPCAMPOS WHERE CAM_TABLE"+GetWhere("=",cTable)+;
                    " AND CAM_NAME"+GetWhere("=",cField),.T.)
  cFieldName:=oTable:FieldGet(1)
  uValue    :=IIF(Empty(uValue),SPACE(oTable:CAM_LEN),uValue)
  oTable:End()

  nLen   :=LEN(uValue)

  oFrmChange:=DPEDIT():New(cTitle,"DPCHANGECOD.edt","oFrmChange",.T.)

  oFrmChange:cCodigoIni   :=uValue        // Trabajador Desde
  oFrmChange:cCodigoFin   :=SPACE(nLen)   // Trabajador Hasta
  oFrmChange:lCodigo      :=.T.
  oFrmChange:nCuantos     :=0
  oFrmChange:cDescriIni   :=SPACE(60)    // Descripción Inicial
  oFrmChange:cDescriFin   :=SPACE(60)    // Descripción Inicial
  oFrmChange:cTabDescri   :="{oDp:"+Alltrim(cTable)+"}"
  oFrmChange:cTable       :=cTable
  oFrmChange:cFieldCod    :=cField
  oFrmChange:cFieldDes    :=cDescri
  oFrmChange:cFieldName   :=cFieldName
  oFrmChange:cFieldDesc   :=cFieldDesc
  oFrmChange:lDelete      :=.F. // Indica si Borra el Origen
  oFrmChange:cWhere       :=cWhere

//  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Tabla"
  @ 3,1 GROUP oGrp TO 4, 21.5 PROMPT "Origen"
  @ 4,1 GROUP oGrp TO 4, 21.5 PROMPT "Destino"

//  @ 2,2 SAY GetFromVar(oFrmChange:cTabDescri)

  @ 3,2 SAY oFrmChange:oDescriIni PROMPT {||oFrmChange:cDescriIni}
  @ 4,2 SAY oFrmChange:oDescriFin PROMPT {||oFrmChange:cDescriFin}

  @ 3,2 SAY oFrmChange:cFieldName
  @ 4,2 SAY oFrmChange:cFieldDesc

  @ 5,2 SAY oFrmChange:cFieldName
  @ 6,2 SAY oFrmChange:cFieldDesc

  // RANGO DE CODIGOS

  @ 4,12 BMPGET oFrmChange:oCodDesde VAR oFrmChange:cCodigoIni;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmChange:lCodigo;
         ACTION oFrmChange:LISTAR(oFrmChange,"cCodigoIni","oCodDesde",.T.);
         VALID oFrmChange:VALCODINI(oFrmChange,oFrmChange:cCodigoIni)

  @ 5,12 BMPGET oFrmChange:oCodHasta VAR oFrmChange:cCodigoFin;
         NAME "BITMAPS\FIND.bmp";
         WHEN oFrmChange:lCodigo;
         ACTION oFrmChange:LISTAR(oFrmChange,"cCodigoFin","oCodHasta",.F.);
         VALID oFrmChange:VALCODFIN(oFrmChange,oFrmChange:cCodigoFin)

// @ 5,1 CHECKBOX oFrmChange:lDelete PROMPT ANSITOOEM("Eliminar Después de Procesar")

/*
  @ 6,07 BUTTON oFrmChange:oBtnIniciar PROMPT "Iniciar " ACTION  (CursorWait(),;
                                    oFrmChange:SetMsg("Ejecutar Actualización"),;
                                    oFrmChange:EJECUTAR(oFrmChange))

  @ 6,10 BUTTON oFrmChange:oBtnCerrar PROMPT "Cerrar  " ACTION oFrmChange:Close() CANCEL
*/

  oFrmChange:oFocus:=oFrmChange:oCodHasta
  oFrmChange:Activate({||oFrmChange:INICIO()})

  EVAL(oFrmChange:oCodDesde:bValid)

RETURN NIL


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oFrmChange:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52,60 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -11 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Ejecutar"; 
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          ACTION (CursorWait(),;
                  oFrmChange:SetMsg("Ejecutar Actualización"),;
                  oFrmChange:CHANGERUN(oFrmChange))

   oBtn:cToolTip:="Guardar"

   oFrmChange:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XCANCEL.BMP";
          TOP PROMPT "Cancelar"; 
          ACTION oFrmChange:CLOSE() CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD


   @ 2,100+30 SAY " "+GetFromVar(oFrmChange:cTabDescri) OF oBar SIZE 220,20 PIXEL BORDER COLOR 0,65535 FONT oFont

   @ 22,100+30 CHECKBOX oFrmChange:lDelete PROMPT "Eliminar Después de Actualizar" OF oBar SIZE 220,20 FONT oFont PIXEL


RETURN .T.


FUNCTION CHANGERUN(oFrmChange)
    LOCAL oTable,oIntRef,cWhere

    IF !MsgNoYes("Desea Unir "+ALLTRIM(oFrmChange:cFieldName)+":"+CRLF+;
                  " El Contenido de : "+CTOSQL(oFrmChange:cCodigoIni)+;
                  " Hacia: "+CTOSQL(oFrmChange:cCodigoFin),"Unir: "+ALLTRIM(GetFromVar(oFrmChange:cTabDescri)))
       RETURN .T.

    ENDIF
    /*
    oTable:=OpenTable("SELECT "+oFrmChange:cFieldCod+" FROM "+oFrmChange:cTable+;
                      " WHERE "+oFrmChange:cFieldCod+GetWhere("=",oFrmChange:cCodigoIni),.T.)
    cWhere:=oTable:cWhere

    oIntRef:=IntRef(oTable) // Guarda el Valor

    
    oTable:cSql:="SELECT "+oFrmChange:cFieldCod+" FROM "+oFrmChange:cTable+;
                 " WHERE "+oFrmChange:cFieldCod+GetWhere("=",oFrmChange:cCodigoFin)

    oTable:Reload()
    */


    // Actualiza los Registros

    oFrmChange:RUNUPDATE()

    /*
    oIntRef:Run(oTable)
    oIntRef:End()

    IF oFrmChange:lDelete
      oTable:Delete(cWhere)
    ENDIF

    oTable:End()
    */
    

RETURN .T.

/*
// Editar 
*/
FUNCTION LISTAR(oFrmChange,cVarName,cVarGet,lInicio)
     LOCAL uValue,lResp,oGet,cWhere:=""
     LOCAL aFields:={oFrmChange:cFieldCod,oFrmChange:cFieldDes}
     LOCAL lGroup :=.F.
     LOCAL cWhere :="" // Debe Excluir el Valor Anterior

     IF !lInicio
        cWhere:=" WHERE "+oFrmChange:cFieldCod+GetWhere("<>",oFrmChange:cCodigoIni)+;
                IIF(Empty(oFrmChange:cWhere),"","AND "+oFrmChange:cWhere)
     ELSE
        cWhere:=" WHERE "+oFrmChange:cFieldCod+GetWhere("<>",oFrmChange:cCodigoFin)+;
                IIF(Empty(oFrmChange:cWhere),"","AND "+oFrmChange:cWhere)
     ENDIF

     oGet  :=oFrmChange:Get(cVarGet)
     uValue:=EVAL(oGet:bSetGet)
     uValue:=EJECUTAR("REPBDLIST",oFrmChange:cTable,aFields,lGroup,cWhere,NIL,NIL,uValue,NIL,NIL,NIL,oGet)

     IF !Empty(uValue)
       oFrmChange:Set(UPPE(cVarName),uValue)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .T.

/*
// Valida Codigo Inicial
*/
FUNCTION VALCODINI(oFrmChange,cCodIni)
   LOCAL oTable,lFound

   oTable:=OpenTable("SELECT "+oFrmChange:cFieldDes+" FROM "+oFrmChange:cTable+;
                     " WHERE "+oFrmChange:cFieldCod+GetWhere("=",cCodIni)+;
                     " AND "  +oFrmChange:cFieldCod+GetWhere("<>",oFrmChange:cCodigoFin),.T.)

   lFound:=(oTable:RecCount()>0)
   oFrmChange:cDescriIni:=oTable:FieldGet(1)
   oFrmChange:oDescriIni:Refresh()
   oTable:End()

   IF !lFound
      oFrmChange:LISTAR(oFrmChange,"cCodigoIni","oCodDesde",.T.)
   ENDIF
  
RETURN .T.

/*
// Valida Codigo Final
*/
FUNCTION VALCODFIN(oFrmChange,cCodFin)
   LOCAL oTable,lFound

   oTable:=OpenTable("SELECT "+oFrmChange:cFieldDes+" FROM "+oFrmChange:cTable+;
                     " WHERE "+oFrmChange:cFieldCod+GetWhere("=",cCodFin)+;
                     " AND "  +oFrmChange:cFieldCod+GetWhere("<>",oFrmChange:cCodigoIni),.T.)

   lFound:=(oTable:RecCount()>0)

   oFrmChange:cDescriFin:=oTable:FieldGet(1)
   oFrmChange:oDescriFin:Refresh()
   oTable:End()

   IF !lFound
      oFrmChange:LISTAR(oFrmChange,"cCodigoFin","oCodHasta",.F.)
   ELSE

   ENDIF
  
RETURN .T.

FUNCTION RUNUPDATE(cNew,cOld)
  LOCAL oCursor,aData:={},cNew:="",cOld:="",I
  LOCAL cWhere:="",cTabla:=oFrmChange:cTable,cField:=oFrmChange:cFieldCod
  LOCAL cFieldD,cFieldS,cTableD,cTableS,cSql

  cWhere:="LNK_TABLES "+GetWhere("=",cTabla)+" AND "+;
          "LNK_FIELDS "+GetWhere("LIKE",'%'+cField+'%')+" AND (LNK_UPDATE=1 OR LNK_DELETE=1) ORDER BY LNK_TABLED"

  cNew:=oFrmChange:cCodigoFin
  cOld:=oFrmChange:cCodigoIni

  aData:=ASQL("SELECT LNK_FIELDD,LNK_FIELDS,0,LNK_TABLED,LNK_TABLES FROM DPLINK WHERE "+cWhere,.T.)

  IF Empty(oFrmChange:cCodigoIni)
    MensajeErr("Debe Seleccionar un Codigo de Origen!")
    RETURN .F.  
  ENDIF

  IF Empty(oFrmChange:cCodigoFin)
    MensajeErr("Debe Seleccionar un Codigo de Destino!")
    RETURN .F.  
  ENDIF

  FOR I=1 TO LEN(aData)

    cFieldD:=aData[I,1] // Campo Destino
    cFieldS:=aData[I,2] // Campo Solicitante
    cTableD:=aData[I,4] // Tabla Destino
    cTableS:=aData[I,5] // Tabla Solicitante

    cFieldD:=GETEXACTFIELD(cFieldS,cFieldD)  

    cWhere:=" WHERE "+cFieldD+GetWhere("=",cOld)
    cSql  :=" SELECT * FROM "+cTableD+" " +cWhere+" LIMIT 1"

    oCursor:=OpenTable(cSql,.T.) // "SELECT * FROM "+cTableD+" " +cWhere+" LIMIT 1",.T.)

    IF oCursor:RecCount()>0
      SQLUPDATE(cTableD,cFieldD,cNew,cWhere)
    ENDIF
    
    oCursor:End()  

  NEXT

  /*
  // Debe Actualizar los campos Virtuales
  */

  cWhere:="LNK_TABLED "+GetWhere("=",ALLTRIM(cTabla))+" AND "+;
          "LNK_FIELDD "+GetWhere("LIKE",'%'+cField+'%')+"  ORDER BY LNK_TABLED"

  cNew:=oFrmChange:cCodigoFin
  cOld:=oFrmChange:cCodigoIni

//aData:=ASQL("SELECT * FROM DPLINK WHERE "+cWhere,.T.)
  aData:=ASQL("SELECT LNK_FIELDD,LNK_FIELDS,0,LNK_TABLED,LNK_TABLES FROM DPLINK WHERE "+cWhere,.T.)

  FOR I=1 TO LEN(aData)

    cFieldS:=aData[I,1] // Campo Destino
    cFieldD:=aData[I,2] // Campo Solicitante
    cTableS:=aData[I,4] // Tabla Destino
    cTableD:=aData[I,5] // Tabla Solicitante

    cFieldD:=GETEXACTFIELD(cFieldS,cFieldD)  

    cWhere :=" WHERE "+cFieldD+GetWhere("=",cOld)
    cSql   :=" SELECT * FROM "+cTableD+" "+cWhere+" LIMIT 1"

    oCursor:=OpenTable(cSql,.T.)

    IF oCursor:RecCount()>0
      SQLUPDATE(cTableD,cFieldD,cNew,cWhere)
    ENDIF
    
    oCursor:End()  

  NEXT

  // 02/08/2024 
  IF cTabla="DPSUCURSAL"
     EJECUTAR("SETCODSUC",oFrmChange:cCodigoIni,oFrmChange:cCodigoFin)
  ENDIF


  IF oFrmChange:lDelete
    SQLDELETE(cTabla,cField+GetWhere("=",cOld))
  ENDIF

  MsgInfo("Proceso Ejecutado Exitosamente")

RETURN .T.

FUNCTION GETEXACTFIELD(cFieldCon,cFieldRes)
  LOCAL cField:="",nAt:=0

  nAt:=AT(oFrmChange:cFieldCod,cFieldCon)

  cField:=SUBSTR(cFieldRes,nAt,10)

  nAt:=AT(",",cField)  // Para Nombres Cortos

  IF nAt>0
    cField:=LEFT(cField,nAt-1)
  ENDIF

  cField:=AllTrim(cField)

RETURN cField

// EOF
