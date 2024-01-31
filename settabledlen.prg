// Programa   : SETTABLEDLEN
// Fecha/Hora : 09/05/2014 01:26:06
// Propósito  : Asignar Longitud de Campos Relacionados
// Creado Por : Juan Navas
// Llamado por: DPTABLASGRID
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,lUpdate)
    LOCAL aFields:={},aLink1:={},I,aLink2:={},aLink3:={},aLink4:={}
    LOCAL aLink  :={},cSql,oLink,nLen,cPrimary,oDb,cDb

    DEFAULT cTable :="DPINV",;
            lUpdate:=.F.

lUpdate:=.T.

    cTable  :=ALLTRIM(cTable)
    cPrimary:=SQLGET("DPCAMPOS","CAM_NAME,CAM_LEN","CAM_TABLE"+GetWhere("=",cTable)+" AND CAM_COMMAN"+GetWhere(" LIKE ","%PRIMA%"))
    nLen    :=DPSQLROW(2)

    IF Empty(cPrimary)
       RETURN .F.
    ENDIF

    cDb     :=SQLGET("DPTABLAS","TAB_DSN","TAB_NOMBRE"+GetWhere("=",cTable))
    oDb     :=OpenOdbc(cDb)
    aFields :=ASQL("SELECT CAM_NAME FROM DPCAMPOS WHERE CAM_TABLE"+GetWhere("=",cTable)+" AND CAM_AFECTA=1")

     cSql:=[ SELECT  LNK_TABLED,LNK_FIELDD,CAM_LEN,LNK_RUN,LNK_FIELDS  ]+;
           [ FROM dplink ]+;
           [ INNER JOIN dpcampos ON LNK_TABLES=CAM_TABLE AND LNK_FIELDS=CAM_NAME ]+;
           [ WHERE LNK_TABLES="DPINV" AND LNK_RUN=1 ]

     oLink:=OpenTable(cSql,.T.)

     WHILE !oLink:Eof()

       IF oLink:CAM_LEN<nLen 
          SQLUPDATE("DPCAMPOS","CAM_LEN",nLen,"CAM_TABLE"+GetWhere("=",oLink:LNK_TABLED)+" AND CAM_NAME"+GetWhere("=",oLink:LNK_FIELDD)) 
          lUpdate:=.T.
       ENDIF

       oLink:DbSkip()

    ENDDO

    IF !lUpdate
       oLink:End(.T.)
       RETURN .F.
    ENDIF

    // debe remover las claves primarias
    oLink:GoTop()
    WHILE !oLink:Eof()
       EJECUTAR("DPGET_FK",oLink:LNK_TABLED,.T.,oDb)
        oLink:DbSkip()
    ENDDO

    // Ampliar el Ancho
    oLink:GoTop()
    WHILE !oLink:Eof()
      EJECUTAR("SETFIELDLEN" ,oLink:LNK_TABLED,oLink:LNK_FIELDD)
       EJECUTAR("SETFIELDLONG",oLink:LNK_TABLED,oLink:LNK_FIELDD,nLen)
        oLink:DbSkip()
    ENDDO

    // Crear Integridad referencial
    oLink:GoTop()
    WHILE !oLink:Eof()
      EJECUTAR("BUILDINTREF",cTable,.T.,oLink:LNK_TABLED,.T.)
        oLink:DbSkip()
    ENDDO
    oLink:End(.T.)

//    AEVAL(aFields,{|a,n,aData| aData:=EJECUTAR("SETFIELDLEN",cTable,a[1]),;
//                               AADD(aLink1,aData)})




// ViewArray(aLink1)

/*
    AEVAL(aLink1  ,{|a,n,aData| aData:=EJECUTAR("SETFIELDLEN",a[1],a[2]),;
                               AADD(aLink2,aData)})

    AEVAL(aLink2 ,{|a,n,aData| aData:=EJECUTAR("SETFIELDLEN",a[1],a[2]),;
                               AADD(aLink3,aData)})


    AEVAL(aLink3 ,{|a,n,aData| aData:=EJECUTAR("SETFIELDLEN",a[1],a[2]),;
                               AADD(aLink4,aData)})
*/

RETURN NIL
// EOF


