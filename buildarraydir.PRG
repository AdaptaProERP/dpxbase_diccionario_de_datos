// Programa   : BUILDARRAYDIR
// Fecha/Hora : 19/07/2023 07:30:39
// Propósito  : Convierte en Arreglo Dirección
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cDir)
  LOCAL aDir:=ARRAY(4)
  LOCAL aText:={},nContar:=0,nLine:=1,nLen:=40

  DEFAULT cDir:="AV. LIBERTADOR, C.C. LIBERTADOR LOCAL 3A, ZONA INDUSTRIAL I"

  aText:=_VECTOR(cDir," ")
  AEVAL(aDir,{|a,n| aDir[n]:=""})

  AEVAL(aText,{|a,n| aText[n]:={a,LEN(a)}})

  WHILE nContar<LEN(aText)
  
    IF LEN(aDir[nLine])+aText[nContar+1,2]<nLen
      aDir[nLine]:=aDir[nLine]+aText[nContar+1,1]+" "
    ELSE
      nLine++
    ENDIF

    nContar++

  ENDDO

  // VIEWARRAY(aDir)
  
RETURN aDir
// EOF
