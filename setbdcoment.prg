// Programa   : SETBDCOMENT
// Fecha/Hora : 10/09/2025 06:29:03
// Propósito  : Asignar Comentarios desde el diccionario de datos.
//              Requiere previamente remover la integridad referencial
// Creado Por : Juan Navas
// Llamado por: Actualizar estructura de la base de de datos o asignar CHARSET 
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDb)
   LOCAL oTable:=OpenTable([SELECT TAB_NOMBRE,TAB_DESCRI FROM DPTABLAS WHERE LEFT(TAB_DSN,1)="<"])
   LOCAL cSql,oDb
   LOCAL cType,nLen,nDec,cTable,cField,cAlter

   DEFAULT cDb:=oDp:cDsnData


   EJECUTAR("DPDROPALL_FK",cDsn)

   oDb:=OpenOdbc(cDb)

   oDb:EXECUTE("SET FOREIGN_KEY_CHECKS = 0")

   // Comenta todas las tablas

   WHILE !oTable:EOF()

     cSql:=[ ALTER TABLE ]+ALLTRIM(oTable:TAB_NOMBRE)+[  COMMENT ]+GetWhere("=",oTable:TAB_DESCRI)

     oDb:EXECUTE(cSql)
     oTable:DbSkip()

   ENDDO

   oTable:End()

   // Comenta todos los campos

   oTable:=OpenTable([SELECT TAB_NOMBRE,CAM_NAME,CAM_DESCRI,CAM_TYPE,CAM_LEN,CAM_DEC FROM DPTABLAS INNER JOIN DPCAMPOS ON CAM_TABLE=TAB_NOMBRE WHERE LEFT(TAB_DSN,1)="<" ORDER BY TAB_NOMBRE ])

   WHILE !oTable:EOF()

      cSql  :=[]
      cType :=oTable:CAM_TYPE
      nLen  :=oTable:CAM_LEN
      nDec  :=oTable:CAM_DEC
      cTable:=oTable:TAB_NOMBRE
      cField:=oTable:CAM_NAME

      IF cType="C"
         cSql:="ALTER TABLE "+cTable+" CHANGE COLUMN "+cField+" "+cField+" VARCHAR("+LSTR(nLen)+")"
      ENDIF

      IF cType="D"
        cSql:="ALTER TABLE "+cTable+" CHANGE COLUMN "+cField+" "+cField+" DATE "
      ENDIF

      IF cType="M"
        cSql:="ALTER TABLE "+cTable+" CHANGE COLUMN "+cField+" "+cField+" LONGTEXT "
      ENDIF

      IF cType="L"
         cSql:="ALTER TABLE "+cTable+" CHANGE COLUMN "+cField+" "+cField+" NUMERIC(1,0)"
      ENDIF

      IF cType="N"
         cSql:="ALTER TABLE "+cTable+" CHANGE COLUMN "+cField+" "+cField+" NUMERIC("+LSTR(nLen)+","+LSTR(nDec)+")"
      ENDIF

      cSql:=cSql+" COMMENT "+GetWhere("",oTable:CAM_DESCRI)

      oDb:EXECUTE(cSql)

      oTable:DbSkip()

   ENDDO


   oTable:End()


RETURN .T.
// EOF

RETURN
