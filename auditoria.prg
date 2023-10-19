// Programa   : AUDITORIA
// Fecha/Hora : 27/09/2009 03:27:52
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :
// oObj       : Es la clase que lo llama, estoy ayuda a mejorar los datos para la auditoria
#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cTipo,lConfig,cTabla,cClave,cTabAud,oObj,cMemo,aFiles,cSClave,nNumero)
   LOCAL nNumMain:=0
   LOCAL oTable,nAt,aTablas

   DEFAULT cTabAud:="",;
           cSClave:="",;
           nNumero:=0,;
           cTabla :=""
  
// evitar tabla WHERE
// ? cTipo,lConfig,cTabla,cClave,cTabAud,oObj,cMemo,aFiles,"EN AUDITORIA"
// ? oDp:lAuditar,"oDp:lAuditar",cTabla,"cTabla"

   IF !oDp:lAuditar .OR. "AUD"$cTabla
      RETURN .F.
   ENDIF

   DEFAULT lConfig:=.T.,cTabla:="",cClave:="" 

   IF Empty(cTabAud)
      cTabAud:=IF(lConfig,"DPAUDITORIA","DPAUDITOR")
   ENDIF

   IF !Empty(cTabla) .AND. Empty(cTabAud)

      aTablas:=GetTables()

      nAt   :=ASCAN(aTablas,{|aVal| aVal[2] == ALLTRIM(cTabla) })

      IF nAt>0 .AND. !aTablas[nAt,10]
         cTabAud:=oDp:cDpAudita
      ENDIF

   ENDIF

   // 19/10/2023 Optimiza la insercion de Registros
   IF lConfig .AND. ValType(oDp:oDPAUDITORIA)="O"
      oTable:=oDp:oDPAUDITORIA
   ENDIF

   IF !lConfig .AND. ValType(oDp:oDPAUDITOR)="O"
      oTable:=oDp:oDPAUDITOR
   ENDIF

   DEFAULT oTable:=OpenTable("SELECT * FROM "+cTabAud,.F.)

   cClave:=IIF( ValType(cClave)="C" , STRTRAN(cClave,"'",'"') , cClave)

   oTable:Append()
   oTable:Replace("AUD_TIPO"  ,cTipo        )
   oTable:Replace("AUD_FECHAS",oDp:dFecha   )
   oTable:Replace("AUD_FECHAO",oDp:dFecha   )
   oTable:Replace("AUD_HORA  ",HORA_AP()    )
   oTable:Replace("AUD_TABLA ",cTabla       )
   oTable:Replace("AUD_CLAVE ",cClave       )
   oTable:Replace("AUD_USUARI",oDp:cUsuario )
   oTable:Replace("AUD_ESTACI",oDp:cPcName  )
   oTable:Replace("AUD_IP"    ,oDp:cIpLocal )
   otable:Replace("AUD_SCLAVE",cSClave      )
   otable:Replace("AUD_NUMERO",nNumero      )

   IF oTable:FieldPos("AUD_MEMO")>0
      oTable:Replace("AUD_MEMO"  ,cMemo        )
   ENDIF

   IF oTable:FieldPos("AUD_FILMAI")>0 .AND. !Empty(aFiles)
     nNumMain:=EJECUTAR("DPFILEEMPADJUNT",aFiles,cClave,cTabla)
     oTable:Replace("AUD_FILMAI",nNumMain )
   ENDIF

   oTable:Commit()

   // 19/10/2023 Optimiza la insercion de Registros
   IF lConfig .AND. oDp:oDPAUDITORIA=NIL
      oDp:oDPAUDITORIA:=oTable
   ENDIF

   IF !lConfig .AND. oDp:oDPAUDITOR=NIL
      oDp:oDPAUDITOR:=oTable
   ENDIF

//   oTable:End() 19/10/2023 Cerrado EN DPFIN o DPLOADCNF

RETURN .T.
//
EOF
