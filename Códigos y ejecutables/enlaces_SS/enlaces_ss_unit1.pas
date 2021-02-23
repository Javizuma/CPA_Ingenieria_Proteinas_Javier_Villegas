unit enlaces_SS_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, biotools, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    FloatSpinEdit1: TFloatSpinEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1; p: TPDB;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.Button1Click(Sender: TObject);
  var
  nomfi: string;
begin
  nomfi:=cargarPDB(p);

  if nomfi<>'' then
  begin

    edit1.text:=nomfi;
    memo1.lines.LoadFromFile(edit1.text);
  end else
  begin
    edit1.text:='';
    memo1.clear;
  end;

end;


//La acción de esto botón permite predecir si dos átomos de azufre de dos residuos de cisteínas distintos
//de una proteína se encuentran enlazadas covalentemente o no.
//Para ello, calcula la distancia entre todos los átomos de azufre de todos los residuos de cisteína de la proteína
//y considera que están enlazados si la distancia que los separa es igual o inferior a una distancia umbral seleccionada por el usuario
procedure TForm1.Button2Click(Sender: TObject);
var
   listaSG: array of integer;
   tabla: TTablaDatos;
   numSG: integer;
  procedure Buscar_SG;
  var
     j: integer;
  begin
    numSG:=0;
    setlength(listaSG,p.numfichas);
    for j:=1 to p.NumFichas do if p.atm[j].ID='SG' then
    begin
      inc(numSG);
      listaSG[numSG]:=j;
    end;
    setlength(listaSG,numSG+1);
  end;

  procedure Calcular_distancias;
  var
     j,k:integer;
  begin
    setlength(tabla,numSG+1,numSG+1);
    for j:=1 to numSG do
        for k:=1 to numSG do
            tabla[j,k]:=distancia(p.atm[listaSG[j]].coor,p.atm[listaSG[k]].coor);

  end;

  procedure Mostrar_Resultados;
  var
     j,k:integer;
     umbral:real;
     aa1,aa2:string;
  begin
    umbral:=floatspinEdit1.value;
    memo2.clear;
    memo2.lines.add('---------------------------------------');
    memo2.lines.add('   PREDICCIÓN DE ENLACES DISULFURO     ');
    memo2.lines.add('---------------------------------------');
    memo2.lines.add('');
    memo2.lines.add(padright('Cisteína-1',15) +padright('Cisteína-2',15) +padright('Distancia',15));
    memo2.lines.add('---------------------------------------');
    for j:=1 to numSG do
        for k:=1 to numSG do
          if (tabla[j,k]<= umbral) and (j<k) then
          begin
            aa1:= 'CYS' + inttostr(p.atm[listaSG[j]].NumRes) + p.atm[listaSG[j]].subunidad;
            aa2:= 'CYS' + inttostr(p.atm[listaSG[k]].NumRes) + p.atm[listaSG[k]].subunidad;
               memo2.lines.add(padright(aa1, 15) + padright(aa2, 15)
               + padright(formatfloat('0.00', tabla[j,k]), 15));
          end;
  end;

begin
  Buscar_SG;
  Calcular_distancias;
  Mostrar_Resultados;
end;


end.

