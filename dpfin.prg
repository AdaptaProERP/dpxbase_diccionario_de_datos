// Programa   : DPFIN
// Fecha/Hora : 01/07/2003 23:02:53
// Propósito  : Validar la Salida del Sistema a Traves de la Opción Salir
// Creado Por : Juan Navas
// Llamado por: Menú Principal
// Aplicación : Todas
// Tabla      : Todas

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lAuto,lChkMdi)
  LOCAL oTable,cIp:=GetHostByName()

  DEFAULT lAuto  :=.F.,;
          lChkMdi:=.T.

  IF lAuto .OR. MsgNoYes("Salir de "+oDp:cDpSys,"Petición de Salida")

    lAuto:=.T. 

    IF lChkMdi .AND. !ChkMdi() // Revisa si hay Ventanas Abiertas
       RETURN .F.
    ENDIF

    AEVAL(DIRECTORY("PLUGIN\*.ZIP") ,{|a,n| FERASE("PLUGIN\"+a[1])})
    AEVAL(DIRECTORY("RELEASE\*.ZIP"),{|a,n| FERASE("RELEASE\"+a[1])})

    IF(ValType(oDp:oDPAUDITOR  )="O",oDp:oDPAUDITOR:End(),NIL)    // 16/10/2023
    IF(ValType(oDp:oDPAUDITORIA)="O",oDp:oDPAUDITORIA:End(),NIL)  // 16/10/2023


    // Requiere la existencia de este campo, para registrar la hora de salida
    IF ISFIELD("DPUSUARIOS","OPE_HORAFI")
      SQLUPDATE("DPUSUARIOS",{"OPE_HORAFI"},{LEFT(TIME(),5)},"OPE_NUMERO"+GetWhere("=",oDp:cUsuario))
    ENDIF

    SQLUPDATE("DPUSUARIOS","OPE_ACTIVO",.T.,"OPE_NUMERO"+GetWhere("=",oDp:cUsuario))

//  SQLUPDATE("DPPCLOG"   ,{"PC_FECHAE","PC_HORAE"},{oDp:dFecha,TIME()},"PC_IP"+GetWhere("=",cIp))

    IF EJECUTAR("DBISTABLE",oDp:cDsnConfig,"DPPCLOG")
      SQLUPDATE("DPPCLOG"   ,{"PC_FECHAE","PC_HORAE"},{oDp:dFecha,TIME()},"PC_NOMBRE"+GetWhere("=",oDp:cPcName))
    ENDIF

    // Salida desde el Boton

    
    IF lAuto
       oDp:cBinExe:=Lower(GetModuleFileName( GetInstance() ))
       FERASE(STRTRAN(oDp:cBinExe,".exe",".txt"))
       oDp:oFrameDp:bValid:={||.T.}  // Inactivo el Valid de Salida
       oDp:oFrameDp:End()
    ENDIF

    SysRefresh()

    IF Empty(SQLGET("DPAUDTIPOS","UDT_CODIGO","UDT_CODIGO"+GetWhere("=","CFIN")))

       oTable:=OpenTable("SELECT * FROM DPAUDTIPOS",.F.)
       oTable:AppendBlank()
       oTable:Replace("UDT_CODIGO","CFIN")
       oTable:Replace("UDT_DESCRI","Salida del Sistema")
       oTable:Replace("UDT_REGIST",.T.)
       oTable:Commit()

    ENDIF

    // Registro de Auditoria salida, del sistema
    AUDITAR("CFIN",.F. ,NIL , "Salida del Sistema",oDp:cDpAudita)

    // Cierra el Servidor
    IF ValType(oDp:oServer)="O"
       oDp:oServer:End()
    ENDIF

    RETURN  .T.

  ENDIF

  // No permite Salir

RETURN .F.
// EOF
