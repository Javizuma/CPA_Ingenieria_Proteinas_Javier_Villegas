
unit biotools;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, Math, Graphics, Dialogs, Forms;

type
  Tpunto = record //almacena las coordenadas X, Y, Z de un átomo
    X, Y, Z: real;
  end;

  TatomPDB = record             //atomo de la prot
    NumAtom: integer;
    ID: string;
    Residuo: string;            //tipo de residuo (O,N, CO...)
    Subunidad: char;
    NumRes: integer;            //nú mero residuo
    coor: Tpunto;
    AltLoc: char;               //posicion alternativa
    Temp: real;

  end;

  TPuntos = array of Tpunto;

  TResiduoPDB = record   //almacena varios datos sobre un residuo
    NumRes: integer;
    Subunidad: char;
    ID3: string;
    ID1: char;               //denominación de una letra
    Atm1, AtmN: integer;
    N, CA, C, O: integer;    //apunta a la ficha de estos átomos del residuo
    phi, psi: real;
end;

  TsubunidadPDB = record
    ID: char;
    atm1, atmN, res1, resN: integer;       // primer y último átomo/residuo de la subunidad
    AtomCount, ResCount: integer;          //número de átomos y de residuos
    ResIndex: array of integer;
end;

  TPDB = record                //estructura de datos que almacena toda la información útil sobre una proteína
    header: string;            //primera línea del archivo PDB que da info de la prot
    atm: array of TAtomPDB;    //conjunto de átomos
    res: array of TResiduoPDB; // array de los residuos
    sub: array of TsubunidadPDB;
    subs,secuencia: string;                //todas las letras que denominan cada subunidad como 'ABCD'
                                           //Secuencia primaria de la proteína KMY...
    NumFichas, NumResiduos: integer;        //como a veces no ponen todos los átomos
    //vamos a contar nosotros los átomos que haya
    NumSubunidades: integer;                // numero total de átomos y de residuos

    AtomIndex: array of integer;

  end;

  TTablaDatos = array of array of real;   //es un array of array of real, de modo
  //que sirve como una tabla bidimensional para almacenar datos

  TEscala = array['A'..'Z'] of real; //array de letras, subíndices de letras


const
  AA = '*****ALA=A#ARG=R#ASN=N#ASP=D'
     + '#CYS=C#GLN=Q#GLU=E#GLY=G#HIS=H'
     + '#ILE=I#LEU=L#LYS=K#MET=M#PHE=F'
     + '#PRO=P#SER=S#THR=T#TRP=W#TYR=Y'
     + '#VAL=V';
 //Se trata de una constante que se utiliza por la función AA3to1 para transformar el identificador de un aminoácido en código de tres letras por el código de una letra

//descriptores de todas las funciones de la librería, que aparecen al completo en el bloque principal tras implementation.
 function distancia(X1,Y1,Z1,X2,Y2,Z2: real):real;
function distancia (punto1, punto2: Tpunto):real; overload;
function CargarPDB(texto: TStrings): TPDB; overload;
function CargarPDB(var p:TPDB): string;
function sumVec(A, B: Tpunto): Tpunto;
function angulo (A, B: Tpunto): real;
function difVec(A, B: Tpunto): Tpunto;
function moduloV(A:TPunto):real;
function escalarV(k:real; V:TPunto):Tpunto;
function prodEscalar(A, B: TPunto): real;
function angulo(A, B, C: TPunto):real; overload;
function torsion(A, B, C, D: Tpunto): real;
function ProdVec(A, B: TPunto): Tpunto;
function AA3to1(AA3: string): char;
function plotXY(datos: TTablaDatos; img: TCanvas; OX: integer = 0;
         OY: integer=1; borrar: boolean=false; linea: boolean=false;
         clpluma: Tcolor = clgreen; clrelleno: TColor=clyellow; clFondo: Tcolor =clblack;
         radio: integer=3; borde: integer= 40; marcafin: boolean=false; clfin: TColor=clred): boolean;
function traslacion (dx, dy, dz: real; v: TPunto): TPunto;
function traslacion (dx, dy, dz: real; Puntos: TPuntos): TPuntos; overload;

function GiroOZ (rad: real; v: TPunto): TPunto;
function GiroOZ (rad: real; puntos: TPuntos): TPuntos; overload;
procedure GiroOZ (rad: real; var p: TPDB); overload;

function GiroOY (rad: real; v: TPunto): TPunto;
function GiroOY (rad: real; puntos: TPuntos): TPuntos; overload;
procedure GiroOY (rad: real; var p: TPDB); overload;

function GiroOX (rad: real; v: TPunto): TPunto;
function GiroOX (rad: real; puntos: TPuntos): TPuntos; overload;
procedure GiroOX (rad: real; var p: TPDB); overload;

function alinear_ejeZ(puntos: Tpuntos): Tpuntos;
function CargarEscala(var escala: TEscala): string;
function CogerSecuencia(texto: TStrings; formato: String): String;
function writePDB(atm: TAtomPDB): string;
function IndDer(maxlong, long: integer; var s: string): string;
function IndIzq(maxlong, long: integer; var s: string): string;

implementation

function writePDB(atm: TAtomPDB): string;
var
  k: integer;
  pdb: TStrings;
  linea, numatm, numre, coordenadaX, coordenadaY, coordenadaZ, temp: String;
  s: string;
begin
  //Lo primero que hacemos es  obtener las cadenas del número de átomo, número de residuo y las coordenadas con el
  //formato de tres decimales que nos interesa.
    numatm:= inttostr(atm.Numatom);
    numre := inttostr(atm.NumRes);
    coordenadaX  := formatfloat('0.000', atm.coor.X);
    coordenadaY  := formatfloat('0.000', atm.coor.Y);
    coordenadaZ  := formatfloat('0.000', atm.coor.Z);
    temp  := formatfloat('0.00', atm.Temp);

    linea:= 'ATOM'+ '  ' + indder(5, numatm.Length, numatm) + '  ' + indizq(3,atm.ID.length, atm.ID) +
            ' ' + atm.Residuo + ' ' + atm.subunidad + ' ' + indder(3, numre.length, numre) +
            '     ' + indder(7, coordenadaX.Length, coordenadaX)+ ' '
            +  indder(7, coordenadaY.length, coordenadaY) + ' ' +
            indder(7, coordenadaZ.Length, coordenadaZ) + '  1.00 ' + indder(5, temp.length, temp);
    //Una vez que todo está listo, se encuadra en la línea con los espacios adecuados.
    //Las coordenadas tienen una longitud máxima de
    // 7 porque hay que tener en cuenta el posible signo - que tengan.
    result:= linea;
  end;


// Adicionalmente se hacen dos funciones que nos permiten indentar el texto que
//nos intere en una longitud máxima, tenemos una para la izquierda y otra para la derecha
//Estas están hechas a partir de un
//código publicado en el siguiente enlace: https://webprogramacion.com/156/pascal/alinear-cadena-por-la-derecha.aspx
//y que hemos adaptado a nuestras necesidades
function IndDer(maxlong, long: integer; var s: string): string;
const
blanco=' ';
var
k:integer;
begin
   if maxlong <> long then
      for k:=1 to maxlong-long do insert(blanco,s,k);
   result:= s;
end;

function IndIzq(maxlong, long: integer; var s: string): string;
const
blanco=' ';
var
k:integer;
begin
   if maxlong <> long then for k:=1 to maxlong-long do
      begin
        s:= s+blanco;
      end;
   result:= s;
end;

//Esta función nos permite extraer la secuencia a partir de un fichero de proteína
function CogerSecuencia(texto: TStrings; formato: String): String;
var
j,i: integer;
sec, linea: String;
p: TPDB;
begin
   if formato = 'PDB' then
   begin

     p:= CargarPDB(texto);
     result:= p.secuencia;
   end;

   if formato = 'GenBank' then
   begin
     sec:='';
     for j:= 0 to texto.count-1 do
     begin

       linea:= texto[j];
       if copy(linea,0,6) = 'ORIGIN' then Break;
       sec:= sec+ trim(linea);
       if copy(linea,22,13) = '/translation=' then sec:= copy(linea, 35, 70);
     end;
     result:= trim(copy(sec,2,sec.Length-2));
   end;

   if formato = 'UniProt' then
   begin
     for j:= 0 to texto.count-1 do
     begin

       linea:= texto[j];
       if copy(linea,0,2) = '//' then Break;
       sec:= sec+ trim(linea);
       if copy(linea,0,2) = 'SQ' then sec:= ' ';
     end;
     result:= trim(sec);
   end;
   end;


//Función que permite cargar una escala de hidrofobicidad, se integra la creación
//de un OpenDialog para facilitar su uso.
function CargarEscala(var escala: TEscala): String;
var
  texto: TStrings; //las lineas que se leen
  linea: String;
  dial: TOpenDialog;
  j: integer;
  lines: string;
  residuo: char;
begin
  texto:= TStringList.Create;   //constructor del texto
  dial:= TOpenDialog.Create(application);    //constructor del opendialogs
  if dial.Execute then
  begin
    texto.loadFromfile(dial.FileName);
    result:= dial.FileName;
    for j:= 0 to texto.count-1 do
    begin
      linea:= trim(texto[j]);   //trim quita espacios
      residuo:= linea[1];
      delete(linea, 1, 1);
      escala[residuo]:= strtofloat(trim(linea));
    end;
  end else result:= '';
  dial.free;
  texto.free;

end;


//AlinearZ: Función que permite alinear los puntos al ejeZ. Como entrada pide un TPuntos y
//como salida devuelve el Tpuntos transformado y ya alineado
function alinear_ejeZ(puntos: Tpuntos): Tpuntos;
var
  salida: TPuntos;
  a, b, c, d1, d2, alfa, fi, senofi, senoalfa: real;
  p1, p2: TPunto;
begin
  setlength(salida, high(puntos)+1);
  p1:= puntos [0];
  salida:= traslacion(-p1.X, -p1.Y, -p1.Z, puntos);
  p2:= salida[high(salida)];

  a:= p2.X; b:= p2.Y; c:= p2.Z;

  d1:= sqrt(sqr(b)+sqr(c));
  d2:= sqrt(sqr(a)+sqr(b)+sqr(c));
  senofi:= b/d1;
  senoalfa:= a/d2;

  fi:= arcsin(senofi);
  alfa:= arcsin(senoalfa);
  if c<0 then fi:= -fi else alfa:= -alfa; //esto recoge los cambios de signos de todos los cuadrantes

  salida:= GiroOX(fi, salida);
  salida:= GiroOY(alfa, salida);
  result:= salida;
end;



//GIROOZ: Función que nos permite generar el giro sobre el eje OZ, se crean tres diferentes
//para poder transformar un punto aislado, un conjunto específico o toda una proteína
function GiroOZ (rad: real; v: TPunto): TPunto;
var
  seno, coseno: real;
begin
  seno:= sin(rad);
  coseno:= cos(rad);
  GiroOZ.X:=v.X*coseno - V.Y*seno;
  GiroOZ.Y:=v.X*seno + V.Y*coseno;
  GiroOZ.Z:=v.Z;
end;

function GiroOZ (rad: real; puntos: TPuntos): TPuntos; overload;
var
seno, coseno:real;
salida:TPuntos;
j:integer;

begin
    seno:= sin(rad);
     coseno:= cos(rad);
     setlength(salida, high(puntos)+1);
     for j:=0 to high(puntos) do
     begin
         salida[j].X:= puntos[j].X*coseno - puntos[j].Y*seno;
         salida[j].Y:= puntos[j].X*seno + puntos[j].Y*coseno;
         salida[j].Z:= puntos[j].Z;
     end;
     result:= salida;
end;

procedure GiroOZ (rad: real; var p: TPDB); overload;
var
   seno, coseno:real;
   j:integer;
begin
    seno:= sin(rad);
    coseno:= cos(rad);
for j:= 1 to p.NumFichas do
   begin
   p.atm[j].coor.X:= p.atm[j].coor.X*coseno - p.atm[j].coor.Y*seno;
   p.atm[j].coor.Y:= p.atm[j].coor.X*seno + p.atm[j].coor.Y*coseno;
   p.atm[j].coor.Z:= p.atm[j].coor.Z;
   end;

 end;


//GIROOY :Función que nos permite generar el giro sobre el eje OY, se crean tres diferentes
//para poder transformar un punto aislado, un conjunto específico o toda una proteína
function GiroOY (rad: real; v: TPunto): TPunto;
var
  seno, coseno: real;
begin
  seno:= sin(rad);
  coseno:= cos(rad);
  GiroOY.X:=v.X*coseno + V.Z*seno;;
  GiroOY.Y:=v.Y;
  GiroOY.Z:=-v.X*seno + V.Z*coseno;
end;

function GiroOY (rad: real; puntos: TPuntos): TPuntos; overload;
var
  seno, coseno:real;
  salida:TPuntos;
  j:integer;
begin
seno:= sin(rad);
coseno:= cos(rad);
setlength(salida, high(puntos)+1);
 for j:=0 to high(puntos) do
     begin
         salida[j].X:= puntos[j].X*coseno + puntos[j].Z*seno;
         salida[j].Y:= puntos[j].Y;
         salida[j].Z:= -puntos[j].X*seno + puntos[j].Z*coseno;
     end;
 result:= salida;
end;
//permite calcular las nuevas coordenadas X, Y, Z de un punto cuando se somete a un giro entorno al eje OY
procedure GiroOY (rad: real; var p: TPDB); overload;
var
  seno, coseno:real;
  j:integer;
begin
   seno:= sin(rad);
   coseno:= cos(rad);
   for j:= 1 to p.NumFichas do
   begin
       p.atm[j].coor.X:= p.atm[j].coor.X*coseno + p.atm[j].coor.Z*seno;
       p.atm[j].coor.Y:= p.atm[j].coor.Y;
       p.atm[j].coor.Z:= -p.atm[j].coor.X*seno +p.atm[j].coor.Z*coseno;

   end;
end;


//Función que nos permite generar el giro sobre el eje OX, se crean tres diferentes
//para poder transformar un punto aislado, un conjunto específico o toda una proteína}
function GiroOX (rad: real; v: TPunto): TPunto;
var           //rad=ángulo en radianes
  seno, coseno: real;
begin
  seno:= sin(rad);
  coseno:= cos(rad);
  GiroOX.X:=v.X;
  GiroOX.Y:=v.Y*coseno - V.Z*seno;
  GiroOX.Z:=v.Y*seno + V.Z*coseno;
end;

//permite calcular las nuevas coordenadas X, Y, Z de un punto cuando se somete a un giro entorno al eje OX
function GiroOX (rad: real; puntos: TPuntos): TPuntos; overload;
var
seno, coseno:real;
   salida:TPuntos;
   j:integer;
begin
    seno:= sin(rad);
     coseno:= cos(rad);
     setlength(salida, high(puntos)+1);
     for j:=0 to high(puntos) do
     begin
         salida[j].X:= puntos[j].X;
         salida[j].Y:= puntos[j].Y*coseno - puntos[j].Z*seno;
         salida[j].Z:= puntos[j].Y*seno + puntos[j].Z*coseno;
     end;
     result:= salida;
end;

procedure GiroOX (rad: real; var p: TPDB); overload;
var
seno, coseno:real;
j:integer;

begin
    seno:= sin(rad);
    coseno:= cos(rad);
       for j:= 1 to p.NumFichas do
       begin
       p.atm[j].coor.X:= p.atm[j].coor.X;
       p.atm[j].coor.Y:= p.atm[j].coor.Y*coseno - p.atm[j].coor.Z*seno;
       p.atm[j].coor.Z:= p.atm[j].coor.Y*seno + p.atm[j].coor.Z*coseno;

       end;
end;


//TRASLACION  Función que nos permite mover un punto la distancia que nos interesa. Se introduce
//la diferencia que se quiera aplicar (dx, dy, dz) a un punto aislado, a un conjunto
//de puntos o a una proteína completa}
function traslacion (dx, dy, dz: real; v: TPunto): TPunto;
begin
  traslacion.X:= v.X+ dx;
  traslacion.Y:= v.Y+ dy;
  traslacion.Z:= v.Z+ dz;
end;

function traslacion (dx, dy, dz: real; Puntos: TPuntos): TPuntos; overload;
var
  salida: TPuntos;
  j: integer;
begin
  setlength(salida, high(puntos)+1);

  for j:=0 to high(puntos) do
  begin
    salida[j].X:= puntos[j].X+ dx;
    salida[j].Y:= puntos[j].Y+ dy;
    salida[j].Z:= puntos[j].Z+ dz;

  end;
  result:= salida;

end;

procedure traslacion(dx, dy, dz: real; var p: TPDB);  //modificamos la proteína entera del tiron
var
  j: integer;
begin
  for j:=1 to p.NumFichas do
  begin
    p.atm[j].coor.X:= p.atm[j].coor.X+dx;
    p.atm[j].coor.Y:= p.atm[j].coor.Y+dy;
    p.atm[j].coor.Z:= p.atm[j].coor.Z+dz;
  end;

end;


//PLOTXY  :Permite representar un TTablaDatos en un TCanvas. Además nos permite seleccionar
//muchos parámetros  tales como el color de pluma, el eje Y, el X, el color
//de lína, si queremos linea, color de relleno, el grosor de los puntos... Por si esto
//no fuera poco redimensiona de manera automática la representación para que se ajute
//al Canvas}

function plotXY(datos: TTablaDatos; img: TCanvas; OX: integer = 0;
         OY: integer=1; borrar: boolean=false; linea: boolean=false;
         clpluma: Tcolor = clgreen; clrelleno: TColor=clyellow; clFondo: Tcolor =clblack;
         radio: integer=3; borde: integer= 40; marcafin: boolean=false; clfin: TColor=clred): boolean;
var
  xmin, xmax, ymin, ymax, rangoX, rangoY: real;
  alto, ancho, j, xp, yp: integer;
  OK: boolean;

  function  xpixel (x: real): integer;
  begin
    result:= round(((ancho-2*borde)*(x-xmin)/rangoX)+borde);

  end;

  function ypixel (y:real): integer;
  begin
    result:= round(alto-(((alto-2*borde)*(y-ymin)/rangoY)+borde));

  end;

begin
  OK:= true;
  xmin:= minvalue(datos[OX]);
  xmax:= maxvalue(datos[OX]);
  ymin:= minvalue(datos[OY]);
  ymax:= maxvalue(datos[OY]);
  rangoX:= xmax-xmin;
  rangoY:= ymax-ymin;
  ancho:= img.width; //es el ancho de la imagen que se le da, número de píxeles horizontales
  alto:= img.Height;
  if (rangoX=0) or (rangoY=0) then OK:= false;

  if borrar then
  begin
    img.brush.color:= clfondo;
    img.clear;
  end;

  if OK then
  begin
    img.pen.color:= clpluma;
    img.brush.color:= clrelleno;

    xp:= xpixel(datos[OX, 0]);
    yp:= ypixel(datos[OY, 0]);
    img.moveto(xp,yp);

    for j:=0 to high(datos[0]) do
    begin
      xp:= xpixel(datos[OX, j]);           //xp es el pixel en el que estmos en concreto
      yp:= ypixel(datos[OY, j]);
      img.Ellipse(xp-radio, yp-radio, xp+radio, yp+radio);
      if linea then img.lineto(Xp, Yp)
    end;

    if marcafin then
    begin
      img.pen.color:=clfin;
      img.brush.color:= clfin;
      img.Ellipse(xp-radio-2, yp-radio-2, xp+radio+2, yp+radio+2);
    end;

  end;
  result:= OK;
end;

//SUMVEC
{Permite sumar dos vectores, representados como un Tpunto}
function sumVec(A, B: Tpunto): Tpunto;
var
  V:Tpunto;
begin
  V.X:= A.X + B.X;
  V.Y:= A.Y + B.Y;
  V.Z:= A.Z + B.Z;

  result:= V;
end;

//DIFVEC
{Permite restar dos vectores, representados como un Tpunto}
function difVec(A, B: Tpunto): Tpunto;
var
  V:Tpunto;
begin
  V.X:= A.X - B.X;
  V.Y:= A.Y - B.Y;
  V.Z:= A.Z - B.Z;

  result:= V;
end;

//MODULOV
{Obtiene el módulo de un vector TPunto a partir de un único argumento de entrada
de tipo TPunto}
function moduloV(A:TPunto):real;
begin
  result:= sqrt(sqr(A.X)+sqr(A.Y)+sqr(A.Z));
end;

//escalarV
//Obtiene el escalar de un vector al multiplicarlo por un número k
function escalarV(k:real; V:TPunto):Tpunto;
begin
  result.X:= k*V.X;
  result.Y:= k*V.X;
  result.Z:= k*V.Z;
end;

//PRODESCALAR
//Calcula el producto escalar entre dos vectores
function prodEscalar(A, B: TPunto): real;
begin
  result:= A.X*B.X + A.Y*B.Y + A.Z*B.Z;

end;

function angulo (A, B: Tpunto): real;
var
  denominador: real;
begin
  denominador:= moduloV(A)*moduloV(B);
  if denominador > 0 then result:= arccos(prodEscalar(A,B)/denominador)
  else result:= maxfloat; //valor absurdo, no podemos poner una cadena pq el resultado debe de ser de tipo real
end;

function angulo(A, B, C: TPunto):real; overload;  //aquí el vértice entre los 3 puntos es B
var
  BA, BC: TPunto;
begin
  BA:= DifVec(A,B);
  BC:=DifVec(C,B);
  result:=angulo(BA, BC);
end;

//PRODESCALAR
//Devuelve el resultado del producto vectorial entre dos vectores
function ProdVec(A, B: TPunto): Tpunto;
var
  V: TPunto;
begin
  V.X:= A.Y*B.Z - A.Z*B.Y;
  V.Y:= A.Z*B.X - A.X*B.Z;      //Matriz
  V.Z:= A.X*B.Y - A.Y*B.X;
  result:= V;
end;

//TORSION
{Función que nos devuelve el valor del ángulo de torsión
entre cuatro vectores de posición. El argumento de entrada son cuatro Tpunto
y el de salida es de tipo real y corresponde con el ángulo de torsión}
function torsion(A, B, C, D: Tpunto): real;
var
  BA, BC, CB, CD, V1, V2, P: TPunto;
  diedro, diedro_IUPAC, denominador, CosGamma: real;

begin
  diedro_IUPAC:= 0;
  BA:= difVec(A,B);
  BC:= difVec(C,B);
  CB:= difVec(B,C);
  CD:= difVec(D,C);
  V1:= prodVec (BC, BA);
  V2:= prodVec (CD, CB);
  diedro:= angulo (V1, V2);
  P:= prodVec(V2,V1);
  denominador:= moduloV(P)*moduloV(CB);
  if denominador>0 then
  begin
    CosGamma:= prodEscalar (P, CB)/denominador;
    if cosGamma>0 then cosGamma := 1 else cosGamma:=-1; //para asegurarnos que es 1 y -1
  end else diedro_IUPAC:= maxfloat; //si va mal

  if diedro_IUPAC<maxfloat then diedro_IUPAC:= diedro*cosGamma;
  result:= diedro_IUPAC;
end;

//AA3to1
{esta función transforma el identificador de un aminoácido en código de tres letras al correspondiente en código de una letra}
function AA3to1(AA3: string): char;  //conversor de código de 3 letras de aa a 1
begin
  result:= AA[pos(AA3, AA)+4];
end;
//AA3to1
{Función que nos permite obtener el identificador en código de 3 letras a partir del
de 1. Para ello hace uso de la constante AA, donde están todos los equivalentes}
function AA1to3(AA1: char): string;  //conversor de código de 1 letras de aa a 3
begin
result:= copy(AA, pos(AA1, AA)-4, 2);
end;

//DISTANCIA
{Nos da la distancia entre dos coordenadas}
function distancia(X1,Y1,Z1,X2,Y2,Z2: real):real;
begin
  result:=sqrt(sqr(X1-X2)+sqr(Y1-Y2)+sqr(Z1-Z2));

end;

//DISTANCIA
{Nos da la distancia entre dos puntos}
function distancia (punto1, punto2: Tpunto):real; overload; //para señalar o indicar que hay 2 funciones con el mismo nombre, sobrecarga
begin
  result:=sqrt(sqr(punto1.X-punto2.X)+sqr(punto1.Y-punto2.Y)+sqr(punto1.Z-punto2.Z));
end;

//CARGARPDB
{Función complementaria a la overload que agiliza su uso ya que crea de manera
automática el Tstrins y el OpenDialog}
function CargarPDB(var p:TPDB): string;   //función alternativa para hacerlo más rapido, devuelve el nombre de la proteína
var
  dialogo: TOpenDialog;
  textoPDB: TStrings; //Idéntico al que pertenece el lines de un memo.
begin

  textoPDB:= TStringList.create;
  dialogo:=TOpenDialog.create(Application); //Creamos el objeto en la aplicación, es un constructor.
  if dialogo.execute then
  begin
    textoPDB.LoadFromFile(dialogo.FileName);
    p:= CargarPDB(textoPDB);                //Se llamaría a la función CargarPDB
    result:= dialogo.FileName;
  end else result:= ' ';                    //Por si no devolvemos ningún fichero de escritura relleno.
  dialogo.free;
  textoPDB.free;

end;

//CARGARPDB OVERLOAD
{A partir de las líneas de un memo(TStrings) nos devuelve un TPDB con todas sus características en una sola vuelta}

function CargarPDB(texto: TStrings): TPDB; overload;
var
  p: TPDB;                           //proteína , El TPDB de salida de la función
  linea: string;
  j,k, F, R, S, resno: integer;      //contador de ficha, residuo, subunidad
begin

  F:=0; R:=0; S:=0;                   //para asegurarse de que el contador es 0 al inicio
  setlength(p.atm, texto.count);     // como no tenemos suficiente info todavía, establecemos el máximo posible,
                                     //que sería el número de líneas total del memo(texto). Estimamos por alto
  setlength(p.res, texto.count);
  setlength(p.sub, texto.count);

  p.secuencia:='';  p.subs:='';

  for j:=0 to texto.count-1 do
  begin
    linea:= texto[j];
    if (copy(linea,1,6)='ATOM  ')then
    begin
      F:= F+1;//no podemos usar j como contador de átomos ya que cuando lelge a ATOM valdrá mucho,
             //necesitamos un contador de fichas a parte
    //ATOMOS
      p.atm[F].NumAtom :=strtoint(trim(copy(linea,7,5)));
      p.atm[F].ID:= trim(copy(linea, 13, 4));
      p.atm[F].Residuo:= copy(linea, 18,3); //no hace falta trim pq siempre son los 3 caracteres
      p.atm[F].Subunidad:=linea[22];       //introduce el caracter 22 del string linea (PUEDE QUE NO HAYA SUBUNIDAD)
      p.atm[F].NumRes:= strtoint(trim(copy(linea,23,4)));
      p.atm[F].coor.X:= strtofloat(trim(copy(linea,31,8)));
      p.atm[F].coor.Y:= strtofloat(trim(copy(linea,39,8)));
      p.atm[F].coor.Z:= strtofloat(trim(copy(linea,47,8)));
      p.atm[F].AltLoc:=linea[17];
      p.atm[F].Temp:= strtofloat(trim(copy(linea, 61,6)));


    //RESIDUO
      if p.atm[F].ID = 'N' then
      begin
        R:= R+1;
        p.res[R].Atm1:= F;
        p.res[R].ID3:=p.atm[F].Residuo;
        p.res[R].ID1:=AA3to1(p.res[R].ID3);
        p.res[R].N:= F;
        p.res[R].NumRes:= p.atm[F].NumRes;
        p.res[R].Subunidad:= p.atm[F].Subunidad;
        p.secuencia:= p.secuencia + p.res[R].ID1;

      //SUBUNIDAD
        if pos(p.atm[F].Subunidad, p.subs)=0 then   //si es cabeza de subunidad (la letra no estaba en subs), se inicia
        begin
          S:= S+1;
          p.subs:= p.subs + p.atm[F].Subunidad;
          p.sub[S].ID:=p.atm[F].Subunidad;
          p.sub[S].atm1:=F;
          p.sub[S].res1:=R;
        end;
      end;
      if p.atm[F].ID='CA' then p.res[R].CA:= F;
      if p.atm[F].ID='C' then p.res[R].C:= F;
      if p.atm[F].ID='O' then p.res[R].O:= F;
      p.res[R].AtmN:= F; //se va a ir cambiando en cada bucle, pero cuando termine se quedará con la el número
                         //del último átomo que se lea dentro del R en cuestión
      p.sub[S].atmN:= F;
      p.sub[S].resN:= R;  //lo mismo pero con la sub


    end;
  end;
  setlength(p.atm, F+1);  //esto es debido a que es una matriz dinamica
  setlength(p.res, R+1);
  setlength(p.sub, S+1);
  p.NumFichas:= F;
  p.NumResiduos:= R;
  p.NumSubunidades:= S;

  setlength(p.AtomIndex, p.atm[p.NumFichas].NumAtom+1);
  //Matriz que relaciona el numFicha con el numAtom. Indice es NumAtom, el contenido es NumFicha
  for j:= 1 to p.Numfichas do p.atomindex[p.atm[j].NumAtom]:= j;

  for j:=1 to p.NumSubunidades do with p.sub[j] do  //pa no tener que ponerlo todo el rato
  begin
    AtomCount:= atmN - atm1 + 1;
    ResCount:= resN - res1 + 1;

    for k:= p.sub[j].res1+1 to p.sub[j].resn-1 do
    begin
      p.res[k].phi:= torsion(p.atm[p.res[k-1].C].coor,
                             p.atm[p.res[k].N].coor,
                             p.atm[p.res[k].CA].coor ,
                             p.atm[p.res[k].C].coor);

      p.res[k].psi:= torsion(p.atm[p.res[k].N].coor,
                             p.atm[p.res[k].CA].coor,
                             p.atm[p.res[k].C].coor,
                             p.atm[p.res[k+1].N].coor);
    end;

    //bucle para los residuos reales frente a ficha
    setlength(p.sub[j].ResIndex, p.NumResiduos+1);
    for k:=1 to p.sub[j].rescount do
    begin
      resno:= p.sub[j].res1+k-1;   //residuo por el que vamos de la subunidad j (residuo primero mas lo que llevemos contado
                                   //-1 porque es matriz abierta (0..n-1)
      p.sub[j].resindex[p.res[resno].numres]:= resno;  //asginación del valor
    end;
  end;

  result:=p;
end;

end.
