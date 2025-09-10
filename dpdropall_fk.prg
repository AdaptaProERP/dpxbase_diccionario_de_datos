// Programa   : DPDROPALL_FK
// Fecha/Hora : 11/02/2015 14:53:08
// Propósito  : Remover toda la Integridad Referencial de Todas las tablas
// Creado Por : Juan Navas
// Llamado por: SQLDB_PREUPDATE
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDsn,cTable,lTrigger)
    LOCAL aTables,oDb,oFrm,cWhere:="",cSql

    DEFAULT cDsn    :=oDp:cDsnData,;
            lTrigger:=.T.
           
    IF !Empty(cTable)

       IF ValType(cTable)="A"
         cWhere:=GetWhereOr("TAB_NOMBRE",cTable)
       ELSE
         cWhere:="TAB_NOMBRE"+GetWhere("=",cTable)
       ENDIF

    ENDIF

    oDb :=OpenOdbc(cDsn)
    cSql:=" SET FOREIGN_KEY_CHECKS = 0"

    oDb:Execute(cSql)

    IF lTrigger
      EJECUTAR("DROPALL_TRIGGER",oDb)
    ENDIF

    aTables:=oDb:GetTables()
    AEVAL(aTables,{|a,n| aTables[n]:={a} })

    ADEPURA(aTables,{|a,n| LEFT(a[1],5)="VIEW_"})

    IF oDp:oSay=NIL 
      oFrm:=MSGRUNVIEW("Removiendo Integridad Referencial","Procesando",LEN(aTables),.F.,.F.)
      DpMsgSetTotal(LEN(aTables))
    ENDIF

    oDb:=OpenOdbc(cDsn)
    oDb:Execute("SET FOREIGN_KEY_CHECKS = 0")

    AEVAL(aTables,{|a,n| DpMsgSet(n,.T.,NIL,a[1]),;
                         IF(oDp:oSay=NIL,NIL,oDp:oSay:SetText("Removiendo INT/REF:"+a[1])),;
                         EJECUTAR("DPDROP_FK" ,UPPE(a[1]),NIL,.T.,.T.,oDb),;
                         SysRefresh(.T.) })

    IF oDp:oSay=NIL
      DpMsgSetTotal(LEN(aTables))
    ENDIF

    AEVAL(aTables,{|a,n| DpMsgSet(n,.T.,NIL,a[1]),;
                         IF(oDp:oSay=NIL,NIL,oDp:oSay:SetText("Removiendo Clave Primaria:"+a[1])),;
                         EJECUTAR("DPDROP_KEY",UPPE(a[1]),NIL,cDsn,oDb),;
                         SysRefresh(.T.) })

    oDb:Execute("SET FOREIGN_KEY_CHECKS = 1")

    // 20/11/2016 Remueve todas las pistas de Intergridad Fallida

    IF EJECUTAR("DBISTABLE",oDp:cDsnConfig,"DPINTREF")
       // Remueve todos los Registros
       SQLDELETE("DPINTREF","INT_BD"+GetWhere("=",cDsn))
    ENDIF

    // Caso de Departamentos debe actualizar la tabla
    SQLUPDATE("DPCAMPOS","CAM_LEN",10,"CAM_TABLE"+GetWhere("=","DPPLADPTO")+" AND CAM_NAME"+GetWhere("=","PLA_CODDEP"))

    IF oDp:oSay=NIL
      DpMsgClose()
    ENDIF
 
RETURN NIL
// EOF


