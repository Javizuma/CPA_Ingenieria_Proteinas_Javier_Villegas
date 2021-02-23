unit Ramachandran_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Menus, biotools, strutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ColorDialog1: TColorDialog;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Image1: TImage;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Primero: TMemo;
    Primero1: TMemo;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Salir(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  Form1: TForm1; datos: TTablaDatos; p:TPDB;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin

   image1.Canvas.clear;
end;

procedure TForm1.Salir(Sender: TObject);
begin

  Halt;
end;

procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton;

  Shift: TShiftState; X, Y: Integer);
begin

    if ColorDialog1.Execute then Shape1.Brush.Color:= ColorDialog1.color;
end;

procedure TForm1.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

     if ColorDialog1.Execute then Shape2.Brush.Color:= ColorDialog1.color;
end;

procedure TForm1.Shape3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

     if ColorDialog1.Execute then Shape3.Brush.Color:= ColorDialog1.color;
end;

procedure TForm1.Button1Click(Sender: TObject);   //Cargamos el fichero
var
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
    memo1.clear
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);     //Calculamos el ramachandran plot y lo
//representamos con PlotXY
var
  pluma,relleno,fondo:TColor;
  j,k:integer;

begin

  pluma:=Shape1.Brush.Color;
  relleno:= Shape2.Brush.Color;
  fondo:= Shape3.Brush.Color;
  memo2.clear;
  for j:=1 to p.NumSubunidades do
  begin

    setlength( datos, 2, p.sub[j].resn-p.sub[j].res1 -1 );
    memo2.visible:=false;

    for k:= p.sub[j].res1+1 to p.sub[j].resn-1 do
    begin

      datos[0,k - p.sub[j].res1-1]:= p.res[k].phi;
      datos[1,k - p.sub[j].res1-1]:= p.res[k].psi;
      memo2.lines.add(padright(p.res[k].ID3 + inttostr(p.res[k].NumRes) + p.res[k].subunidad,10)
                                            +padleft(formatfloat('0.00', p.res[k].phi*180/pi),10)
                                            +padleft(formatfloat('0.00', p.res[k].psi*180/pi),10));
    end;

    memo2.visible:=true;
    plotXY(datos,image1.Canvas,0,1,false,false,pluma,relleno,fondo);

  end;
end;

end.
