// Programa   : DPTABLANODICCDAT
// Fecha/Hora : 12/01/2017 15:06:59
// Propósito  : Importar la tabla que no existe desde el diccionario de datos, en caso no existir descargar 
// Creado Por : Juan Navas
// Llamado por: GETDSN/DPODBC.PRG
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,lSay,lField,aTablas,cNumTab)
   LOCAL I,U,aTablas:={},cDir:="DATADBF\",cTemp
   LOCAL cTableDbf:=cDir+"DPTABLAS.DBF"
   LOCAL lAdd:=.F.,lFound:=.F.
   LOCAL cField,cCopy,cDirTmp:="TEMP\DATADBF\"
   LOCAL cFileTxt
   LOCAL lFind,lResp:=.F.,cVista:="",aTablas:={},U,cTabla // Si descargó la Vista
   LOCAL cDsn,aStruct
   LOCAL oDb:=OpenOdbc(oDp:cDsnConfig)

//? cTable,lSay,lField,aTablas,cNumTab,"cTable,lSay,lField,aTablas,cNumTab",GETPROCE()
   
   DEFAULT cTable:="NMTRABAJADOR",;
           lSay  :=.T.,;
           lField:=.F.,;
           oDp:lDiccServer:=.T.

   DEFAULT oDp:oMsgRun:=NIL

// ? cTable,CLPCOPY(GETPROCE())
// cTable:="VIEW_DPDIARIO_CUATRI" // Quitar
// Si no esta en tablas DBF lo Importa desde STRUCT\
// ? cTable,"cTable",GETPROCE()

   IF Empty(cTable)
      // MensajeErr("Requiere cTable","DPTABLANODICCDAT")
      RETURN .T.
   ENDIF

   IF !oDp:oSay=NIL
     oDp:oSay:SetText("Buscando Tabla "+cTable)
   ELSE
     MsgRun("Buscando Tabla "+cTable)
   ENDIF

   cDsn:=SQLGET("DPTABLAS","TAB_DSN","TAB_NOMBRE"+GetWhere("=",cTable),NIL,oDb)

   EJECUTAR("FILETOSCRSAY",cTable)

IF lSay

   IF ValType(oDp:oMsgRun)="O"
      oDp:oMsgRun:oSay:SetText("Tabla "+cTable+" No Encontrada en el Diccionario de Datos")
   ELSE
      // MsgRun("Tabla "+cTable+" No Encontrada en el Diccionario de Datos","Buscando Tabla ")

      IF !oDp:oSay=NIL
        DpMsgRun("Buscando Tabla "+cTable+" en "+IF(Empty(cDsn),"Indefinida",cDsn),"No Encontrada en la Base de Datos")
      ELSE
        oDp:oSay:SetText("Buscando Tabla "+cTable)
      ENDIF
   ENDIF

ENDIF

   IF LEFT(cTable,5)="VIEW_"
     RETURN EJECUTAR("TXTTODPVISTAS",cTable,.T.)
   ENDIF

   // 26/11/2020, crea la tabla desde el diccionario de Datos

   aStruct:=EJECUTAR("MYLOADSTRUCT",cTable) 

   IF ValType(aStruct)="A" .AND. LEN(aStruct)>0 .AND. !Empty(cDsn)

     ErrorSys(.T.)
     Checktable(cTable)

     RETURN .T.

   ENDIF

   oDb     :=OpenOdbc(oDp:cDsnConfig)  
   cFileTxt:="STRUCT\"+cTable+".TXT"

   IF !FILE(cFileTxt) .AND. ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable,oDb))
     EJECUTAR("EJMIMPDATOS",cTable)
   ENDIF

   // descarga desde el FTP
   IF !FILE(cFileTxt)
      FTPFROMADP(cFileTxt)
   ENDIF

// cTable:="VIEW_CAJACXC_CXP"
/*
  IF "VIEW_"$UPPER(cTable)

    // La busca en DATADBF\DPVISTAS.DBF
    AADD(aTablas,{"DPVISTAS","VIS_VISTA"})

    FOR U=1 TO LEN(aTablas)

     EJECUTAR("DPFILSTRTAB",aTablas[U,1],.T.)
 
     cTabla:=cDir+aTablas[U,1]+".DBF"

     IF FILE(cTabla) 
       USE
       USE (cTabla)

       UPDATETABLE(aTablas[U,1],cTabla ,aTablas[U,2],oDp:cDsnConfig,NIL,.T.,.T.)

      ENDIF

     NEXT

     cVista:=SUBS(cTable,6,LEN(cTable))

     IF EJECUTAR("TXTTODPVISTAS",cVista)

       oDp:lCreateView:=.T.

       EJECUTAR("SETVISTAS",NIL,cVista)
       
     ENDIF

     cDsn     :=SQLGET("DPVISTAS","VIS_DSN","VIS_VISTA"+GetWhere("=",cVista))

// ? cDsn

     IF EJECUTAR("DBISTABLE",cDsn,cVista) // cTable)
        // Logró Construirla
        DpMsgClose()
        RETURN .T.
     ENDIF


     cTableDbf:=STRTRAN(cTable,"VIEW_","")+".VIS"
     cDirTmp  :="DOWNLOAD\DPVISTAS\"

     DpMsgRun("Descargando Vista "+cTable+" Desde AdaptaPro Server","Por favor espere",{||DPAPTGET(cTableDbf,cDirTmp,.F.),;
                           cTableDbf:=cDirTmp+cTableDbf,;
                           lResp    :=FILE(cTableDbf)  ,;
                           EJECUTAR("VISTODPVISTAS",cDirTmp)})
     DpMsgClose()

     RETURN lResp

  ENDIF
*/

  IF Empty(cTable) // .OR. !oDp:lDiccServer
     RETURN .F.
  ENDIF

  EJECUTAR("DPCREATEFROMTXT",cTable,.T.)

  DPWRITE("TEMP\DPTABLANODICCDAT.TXT",cTable+CRLF+GETPROCE())

  lFind:=.F.

  AADD(aTablas,{"DPTABLAS"      ,"TAB_NOMBRE"                                 })
  AADD(aTablas,{"DPCAMPOS"      ,"CAM_TABLE,CAM_NAME"                         })
  AADD(aTablas,{"DPCAMPOSOP"    ,"OPC_TABLE,OPC_CAMPO,OPC_TITULO"             })
  AADD(aTablas,{"DPLINK"        ,"LNK_TABLES,LNK_TABLED,LNK_FIELDS,LNK_FIELDD"})

  // Tablas Base del Diccionario de Datos

  FOR I=1 TO LEN(aTablas)

       IF !EJECUTAR("ISTABLE",oDp:cDsnConfig,aTablas[I,1])

         EJECUTAR("DPFILSTRTAB",aTablas[I,1],.T.)

         cTemp:="DATADBF\"+aTablas[I,1]+".dbf"

         IF FILE(cTemp) 
           UPDATETABLE(aTablas[I,1],cTemp ,aTablas[I,2],oDp:cDsnConfig,NIL,.T.,.T.)
         ENDIF

       ENDIF

  NEXT I 

  IF EJECUTAR("ISTABLE",oDp:cDsnConfig,"DPTABLAS")

    lFind:=ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable))
     
    IF !Empty(cTable) .AND. !lFind .AND. FILE(cFileTxt)

    
      EJECUTAR("DPFILSTRTAB",cTable,.T.)
      oDp:oFileCopy:=TFile():New("DPXBASE\DPXBASE.TXT")
      oDp:oFileCopy:AppStr("<"+cFileNoPath(cTable)+">"+CRLF)
      oDp:oFileCopy:Close()

      lFind:=ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable))

    ENDIF

   ENDIF

   IF Empty(cTable) // .OR. !oDp:lDiccServer
      RETURN .F.
   ENDIF

   IF lFind

      IF ValType(cTable)="C"
        ErrorSys(.T.)
        CheckTable(cTable)
      ENDIF

      RETURN .T.
   ENDIF

   lmkdir(cDirTmp)

   // Debe Buscar la Tabla en el Diccionario Actual

   IF !FILE(cTableDbf)
      MensajeErr("Tabla "+cTableDbf+" no Existe","DPTABLANODICCDAT")
      RETURN .F.
   ENDIF

   CLOSE ALL
   SELECT A
   USE (cTableDbf) EXCLU

// BROWSE()

   IF Empty(ALIAS())
      MensajeErr("Tablas "+cTableDbf+" no puede ser Abierto")
      CLOSE ALL
      RETURN .F.    
   ENDIF

   cTable:=ALLTRIM(cTable)

// BROWSE()

   GO TOP 
   SET FILTER TO (ALLTRIM(A->TAB_NOMBRE)==cTable)
   GO TOP

   lFound:=!EMPTY(A->TAB_NOMBRE)

// IF Empty(A->TAB_NOMBRE) .OR. lField

   IF !lFound .OR. lField

      // Descarga la Tabla desde el Servidor
      USE

      FOR I=1 TO LEN(aTablas)
        cTemp:=cDirTmp+aTablas[I,1]+".dbf"
        ferase(cTemp)
      NEXT I

      cTableDbf:=cTable+".PAQ"

      DpMsgRun("Descargando Tabla "+cTable+" Desde AdaptaPro Server","Por favor espere",{||DPAPTGET(cTableDbf,cDirTmp,.F.),;
                           EJECUTAR("PAQTODPTABLAS",cDirTmp)})

      FOR I=1 TO LEN(aTablas)

        cTemp:=cDirTmp+aTablas[I,1]+".dbf"

        IF FILE(cTemp) 
          lAdd:=.T.
          UPDATETABLE(aTablas[I,1],cTemp ,aTablas[I,2],oDp:cDsnConfig,NIL,.T.,.T.)
        ENDIF

      NEXT I

   ELSE

      USE

      // Copiar los datos de la Tabla hacia una carpeta temporal

      FOR I=1 TO LEN(aTablas)

        cTableDbf:=cDir+aTablas[I,1]
        cField   :=_VECTOR(aTablas[I,2])[1]
        cCopy    :="ALLTRIM("+cField+")"+GetWhere("=",cTable)

        CLOSE ALL

        USE (cTableDbf)
        SELECT A
        SET FILTER TO (&cCopy)
        GO TOP

//      IF RECCOUNT()>0
        IF !EMPTY(A->(FIELDGET(1)))
	      lAdd:=.T.
        ENDIF

        GO TOP
        cTemp:=cDirTmp+aTablas[I,1]+".dbf"

        ferase(cTemp)
        COPY TO (cTemp)
        SELECT A
        USE

        UPDATETABLE(aTablas[I,1],cTemp ,aTablas[I,2],oDp:cDsnConfig,NIL,.T.,.T.)

      NEXT I

   ENDIF

   SELECT A
   USE

   // Si no esta en tablas DBF lo Importa desde STRUCT\
   lFind:=COUNT("DPTABLAS","TAB_NOMBRE"+GetWhere("=",cTable),oDb,.F.)>0

   IF !lFind 

     cFileTxt:="STRUCT\"+cTable+".TXT"

     IF FILE(cFileTxt)
       EJECUTAR("DPFILSTRTAB",cTable,.T.)
     ELSE
       RETURN .F.
     ENDIF
   ENDIF

   // Recarga las Tablas

   IF lAdd
     LOADTABLAS(.T.)
     Checktable(cTable)
   ENDIF

RETURN lAdd
// EOF
