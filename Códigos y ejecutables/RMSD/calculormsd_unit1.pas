unit CalculoRMSD_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, biotools;

type
  TMatrizRMSD = array[1..6] of array[1..6] of real;
  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1; p:TPDB;
  cys1, cys2, cys3: integer;
  tabla1, tabla2, tabla3: TMatrizRMSD;

implementation
//Javier Villegas Salmerón 15/02/2021
{$R *.lfm}

{ TForm1 }


//Este botón sirve para cargar la proteína
procedure TForm1.Button1Click(Sender: TObject);
var
  nomfi: string;
begin
  memo1.clear;
  memo2.clear;
  memo3.clear;
  nomfi:= cargarPDB(p);
  if nomfi <>'' then
  begin
  edit1.text:= nomfi;
  memo1.lines.LoadFromFile(edit1.text);
  end else
  begin
    edit1.text:='Fichero no encontrado';
    memo1.clear;
    memo2.clear;
    memo3.clear;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
 var
k,n,j:integer;
begin
  n:=0;
  j:=0;
  memo2.lines.add('Las 3 primeras cisteínas son: ');
  memo3.lines.add('');
  for k:=0 to p.NumResiduos-1 do
    begin
    if (p.res[k].ID3='CYS') and (n<>3) then
      begin
      n:=n+1;
      if n=1 then
        begin
        cys1:=p.res[k].NumRes; //Nos va a servir para almacenar la posición de las cisteínas
        memo2.lines.add(inttostr(p.res[k].NumRes));
        end;
      if n=2 then
        begin
        cys2:=p.res[k].NumRes; //Nos va a servir para almacenar la posición de las cisteínas
        memo2.lines.add(inttostr(p.res[k].NumRes));
        end;
      if n=3 then
        begin
        cys3:=p.res[k].NumRes; //Nos va a servir para almacenar la posición de las cisteínas
        memo2.lines.add(inttostr(p.res[k].NumRes));
        end;
      end;
    end;
    end;

procedure TForm1.Button3Click(Sender: TObject);
 var
   j,k, g, d: integer; //Las usamos para rellenar las matrices
   m, n, i: integer; //Las usamos para realizar el cálculo de RMSD
   suma1, suma2, suma3: real;
   RMSD_12, RMSD_13, RMSD_23:real; //Aquí guardamos los resultados de calcular RMSD
 begin

   d:= 1;
   for j:= p.res[cys1].atm1 to p.res[cys1].AtmN do
    begin
      g:= 1; //reinicio el contador del segundo bucle
      for k:= p.res[cys1].atm1 to p.res[cys1].AtmN do
       begin
       tabla1[d,g] := distancia(p.atm[j].coor, p.atm[k].coor); //rellenamos la matriz con los valores
       g:= g+1;
       end;
    d:= d+1;
    end;

    //Ahora pasamos a rellenar la segunda matriz
    d:=1;
    for j:= p.res[cys2].atm1 to p.res[cys2].AtmN do
    begin
       g:=1;    //segundo bucle
      for k:= p.res[cys2].atm1 to p.res[cys2].AtmN do
       begin
       tabla2[d,g] := distancia(p.atm[j].coor, p.atm[k].coor); //rellenamos la matriz con los valores
       g:=g+1;
       end;
    d:= d+1;
    end;

    //Ahora pasamos a llenar la tercera matriz
    d:=1;
   for j:= p.res[cys3].atm1 to p.res[cys3].AtmN do
    begin
      g:=1;
      for k:= p.res[cys3].atm1 to p.res[cys3].AtmN do
       begin
        tabla3[d,g] := distancia(p.atm[j].coor, p.atm[k].coor); //rellenamos la matriz con los valores
        g:=g+1;
       end;
    d:= d+1;
    end;



   //Una vez tenemos las matrices con los valores el cálculo es bastante sencillo
   suma1:= 0;
   //Calculamos el valor de RMSD 1-2
   for m:=1 to 6 do
    for n:=1 to 6 do
      begin
         suma1:= suma1 + sqr(tabla1[m,n]-tabla2[m, n]);
      end;
    RMSD_12:=sqrt(suma1/6);

    suma2:= 0;
   //Calculamos el valor de RMSD 1-3
   for m:=1 to 6 do
    for n:=1 to 6 do
      begin
         suma2:= suma2 + sqr(tabla1[m,n]-tabla3[m, n])
      end;
    RMSD_13:=sqrt(suma2/6);

    suma3:= 0;
   //Calculamos el valor de RMSD 2-3
   for m:=1 to 6 do
    for n:=1 to 6 do
      begin
         suma3:= suma3 + sqr(tabla2[m,n]-tabla3[m, n])
      end;
    RMSD_23:=sqrt(suma3/6);

    memo3.lines.add('----------RMSD entre las CYS----------');
    memo3.lines.add('');
    memo3.lines.add('RMSD entre CYS1 y CYS2:  ' + formatfloat('0.0000', RMSD_12));
    memo3.lines.add('RMSD entre CYS1 y CYS3:  ' + formatfloat('0.0000', RMSD_13));
    memo3.lines.add('RMSD entre CYS2 y CYS3:  ' + formatfloat('0.0000', RMSD_23));
 end;



end.


