unit AlinearZ_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
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
    Label2: TLabel;
    Memo1: TMemo;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  p: TPDB;
  CAI,CAT: TPuntos;
  CA1,CAn: integer;
  datos: TTablaDatos;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  image1.canvas.clear;
  image2.canvas.clear;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  nomfi: string;
begin
  nomfi:=cargarPDB(p);

  if nomfi<>'' then
  begin

    edit1.text:=nomfi;
    memo1.lines.LoadFromFile(edit1.text);
    SpinEdit1.maxvalue:=p.NumResiduos;
    SpinEdit2.maxvalue:=p.NumResiduos;
    SpinEdit1.minvalue:=1;
    SpinEdit2.minvalue:=1;
    CA1:=1; CAn:=p.NumResiduos;
  end else
  begin
    edit1.text:='';
    memo1.clear;
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  j:integer;
begin

  CA1:=SpinEdit1.value;
  CAn:=SpinEdit2.value;
  if CA1>CAn then
  begin
  j:=CA1; CA1:=CAn; CAn:=j;
  end;
  setlength(CAI, CAn-CA1+1);
  setlength(datos,2,CAn-CA1+1);

  for j:=CA1 to CAn do CAI[j-CA1]:=p.atm[p.res[j].CA].coor;

  for j:=0 to high(CAI) do
  begin
    datos[0,j]:=CAI[j].X;
    datos[1,j]:=CAI[j].Y;

  end;
  plotXY(datos,image1.canvas,0,1,true,true);
  CAT:= alinear_ejeZ(CAI);
  for j:=0 to high(CAI) do
  begin
    datos[0,j]:=CAT[j].X;
    datos[1,j]:=CAT[j].Y;
  end;
  plotXY(datos,image2.canvas,0,1,true,true,clgreen,clgreen,clblack,3,40,true);
end;

end.

