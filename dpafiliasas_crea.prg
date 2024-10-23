// Programa   : DPAFILIASAS_CREA
// Fecha/Hora : 23/10/2024 05:34:36
// Propósito  : Registro de Afiliados para acceder mediante SAS
// Creado Por : Juan Navas
// Llamado por: DPINIADDFIELD       
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL aFiles:={}
   LOCAL cCodigo,cDescri,lRun,cSql
   LOCAL oDb:=OpenOdbc(oDp:cDsnConfig)
   
   oDp:cCodSas:=STRZERO(0,4)

   IF !ISSQLFIND("DPTABLAS","TAB_NOMBRE"+GetWhere("=","DPAFILIASAS"))

     AADD(aFields,{"SAS_ID"    ,"C",004,0,"Código Afiliado"    ,""})
     AADD(aFields,{"SAS_LOGIN" ,"C",120,0,"Login de Acceso"    ,""}) // Vincula con el Codigo del Usuario
     AADD(aFields,{"SAS_NOMBRE","C",120,0,"Nombre del Afiliado",""})
     AADD(aFields,{"SAS_FCHINI","D",10,0,"Desde"               ,""})
     AADD(aFields,{"SAS_FCHFIN","D",10,0,"Hasta"               ,""})
     AADD(aFields,{"SAS_ACTIVO","L",01,0,"Activo"              ,""})

     EJECUTAR("DPTABLEADD","DPAFILIASAS","Afiliaciones SAS",".CONFIGURACION",aFields)

     EJECUTAR("SETPRIMARYKEY","DPAFILIASAS" ,"SAS_ID",.T.)

  ENDIF

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPEMPRESA","EMP_CODSAS")
     EJECUTAR("DPCAMPOSADD","DPEMPRESA"  ,"EMP_CODSAS","C",4,0,"Código Afilicación SAS",NIL)
     EJECUTAR("DPINDEXADD" ,"DPEMPRESA"  ,"EMP_CODSAS","Código de Afiliación","AFILIACION_SAS") 
     EJECUTAR("DPLINKADD"  ,"DPAFILIASAS","DPEMPRESA","SAS_ID","EMP_CODSAS",.T.,.T.,.T.)
  ENDIF

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPUSUARIOS","USU_CODSAS")
     EJECUTAR("DPCAMPOSADD","DPUSUARIOS"  ,"USU_CODSAS","C",4,0,"Código Afilicación SAS",NIL)
     EJECUTAR("DPINDEXADD" ,"DPUSUARIOS"  ,"USU_CODSAS","Código de Afiliación","AFILIACION_SAS") 
     EJECUTAR("DPLINKADD"  ,"DPAFILIASAS","DPUSUARIOS","SAS_ID","USU_CODSAS",.T.,.T.,.T.)
  ENDIF

RETURN .T.
// EOF
