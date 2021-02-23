unit Estereodiagrama_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, biotools;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1; p: TPDB; datos,datos2: TTablaDatos;
  CAI, CAT: TPuntos;  // conjuntos de puntos sin transformar y transformados
  CA1, CAN, numphe: integer;  // números del CA inicial y CA final

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  image1.canvas.clear;
  image2.canvas.clear;
  memo1.visible:=false;
  spinedit1.visible:=false;
  label1.visible:=false;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  j:integer;
  nomfi: string;
begin
  nomfi:= cargarPDB(p);
  if nomfi<>'' then
  begin
  edit1.text:= nomfi;
  memo1.lines.LoadFromFile(edit1.text);

  end else
  begin
    edit1.text:= '';
    memo1.clear;
  end;
  numphe:=0; //Calculamos el número de Phe que tiene la proteína para luego dar al usuario
  //la oportunidad de usar la que quiera
  for j:=0 to p.NumFichas do
       begin
       if p.res[j].ID3='PHE' then numphe:=numphe+1;
       end;
  if numphe<>0 then spinedit1.maxvalue:=numphe;
  spinedit1.visible:=true;
  label1.visible:=true;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
j,k, choosedphe, counterphe:integer;
begin
 choosedphe:=spinedit1.value;
 counterphe:=0;
 for j:=0 to p.NumFichas do
 begin
 if p.res[j].ID3='PHE' then
    begin
    counterphe:=counterphe+1;
    if  counterphe=choosedphe then
        begin
        CA1:=j;
        break
        end;
    end;
 end;
 CAN:=CA1+2;

 setlength(CAI,p.res[CAN].AtmN+1-p.res[CA1].Atm1 ); // la longitud necesaria es el conjunto de puntos
 setlength(datos,2, p.res[CAN].AtmN+1-p.res[CA1].Atm1); // misma longitud para los datos pero con dos columnas
 for j:= p.res[CA1].Atm1 to p.res[CAN].AtmN do CAI[j-p.res[CA1].Atm1]:= p.atm[j].coor;

 for j:=p.res[CA1].Atm1 to p.res[CAN].AtmN  do // recorre todos los TPuntos
 begin
   datos[0,j-p.res[CA1].Atm1]:= CAI[j-p.res[CA1].Atm1].X;    //los datos para cada Tpunto en la x
   datos[1,j-p.res[CA1].Atm1]:= CAI[j-p.res[CA1].Atm1].Y;   // para la y
 end;
 plotxy(datos, image1.Canvas, 0, 1, true, true, clyellow, clyellow,clblack,2,20,false,clred);
 // queremos que borrar sea true, por lo que tenemos que poner todos
 // los datos al menos hasta ahí. lo mismo para línea.
 CAT:= giroOY(0.0873,CAI); // los datos transformados se obtienen alineando los iniciales
 for j:= p.res[CA1].Atm1 to p.res[CAN].AtmN do
 begin
 datos[0,j-p.res[CA1].Atm1]:= CAT[j-p.res[CA1].Atm1].X;
 datos[1,j-p.res[CA1].Atm1]:= CAT[j-p.res[CA1].Atm1].Y;
 end;
 plotxy(datos, image2.canvas, 0, 1, true, true,clyellow,clyellow,clblack,2,20,false,clred); // plot del segundo ya transformado
end;
end.

