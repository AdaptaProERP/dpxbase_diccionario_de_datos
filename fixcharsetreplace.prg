// Programa   : FIXCHARSETREPLACE
// Fecha/Hora : 11/08/2021 21:36:25
// Propósito  : Reemplazar Caracteres distorcionados causados por cambios de CHARSET
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,lConfig,oSay,oMeter)
  LOCAL aFields:={},I,aTablas:={},cSql:="",U,Z,oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL aData,aReplace,cData,cReplace

//  cData   :={"Ã©","Ã³","Ã-­" },;
//  cReplace:={"é" ,"ó" ,"í"  }

  DEFAULT lConfig:=.F.

  aData:=MEMOREAD("DP\REPLACE.TXT")

  CursorWait()


  IF Empty(aData)
     MensajeErr("Necesario Archivo DP\REPLACE.TXT contentivo de busquedas y reemplazo")
     RETURN NIL
  ENDIF

  aData:=STRTRAN(aData,CRLF,CHR(10))
  aData:=_VECTOR(aData,CHR(10))

  aReplace:=_VECTOR(aData[2],",")
  aData   :=_VECTOR(aData[1],",")

// ViewArray(aData)
// ViewArray(aReplace)

  IF Empty(cTable)

    aTablas:=ACLONE(oDp:aTablas)

    IF !lConfig
       ADEPURA(aTablas,{|a,n| !UPPER(a[3])==UPPER(oDp:cDsnData) 	})
    ELSE
       ADEPURA(aTablas,{|a,n| UPPER(a[3])==UPPER(oDp:cDsnData) 	})
    ENDIF

  ELSE

    aTablas:={}
    AADD(aTablas,{NIL,cTable})

  ENDIF

// ViewArray(aTablas)
// SysRefresh(.T.)
// ? oSay:ClassName(),oMeter:ClassName()

  DEFAULT aTablas:={}

  cSql:=" SET FOREIGN_KEY_CHECKS = 0"
  oDb:Execute(cSql)

// ? oSay:ClassName(),oMeter:ClassName()
// ? ValType(aTablas)


  IF ValType(oMeter)="O"
     oMeter:SetTotal(LEN(aTablas))
     oMeter:Refresh(.T.)
// ? LEN(aTablas)
  ENDIF

// RETURN

  FOR I=1 TO LEN(aTablas)

     cTable:=aTablas[I,2]

     IF ValType(oSay)="O"
       oSay:SetText(cTable,.T.)
     ENDIF

     IF ValType(oMeter)="O" .AND. I%10=0
       oMeter:Set(I)
       oMeter:Refresh(.T.)
     ENDIF

     aFields:=EJECUTAR("MYSQLSTRUCT",cTable)
     aFields:=ADEPURA(aFields,{|a,n| !a[2]="C"})
     aFields:=ADEPURA(aFields,{|a,n|  a[3]<3  })

     cSql:=""

     FOR U=1 TO LEN(aFields)

       FOR Z=1 TO LEN(aData)
          cSql:=cSql+IF(Empty(cSql),"",","+CRLF)+aFields[U,1]+[=REPLACE(]+aFields[U,1]+","+GetWhere("",aData[Z])+","+GetWhere("",aReplace[Z])+")"
       NEXT Z

     NEXT U

     IF !Empty(cSql)

       cSql:=" UPDATE "+cTable+CRLF+;
             " SET "+cSql

       oDb:Execute(cSql)

       SysRefresh(.T.)
       CursorWait()

     ENDIF

// ? cSql

   NEXT I

   cSql:=" SET FOREIGN_KEY_CHECKS = 1"
   oDb:Execute(cSql)

RETURN .T.
// EOF
