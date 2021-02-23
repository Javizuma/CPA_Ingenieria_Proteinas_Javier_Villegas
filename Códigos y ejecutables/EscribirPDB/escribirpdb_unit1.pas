unit EscribirPDB_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, biotools;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1; p: TPDB;

implementation

{$R *.lfm}

{ TForm1 }

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

procedure TForm1.Button2Click(Sender: TObject);  //Botón cuya función es extraer los CA del fichero
var
  j: integer;
begin
  memo2.visible:= false;
                  for j:= 1 to p.NumFichas do
                   begin   //Si hay 'CA' guardamos sus valores
                    if p.atm[j].ID= 'CA' then memo2.Lines.Add(writePDB(p.atm[j]));
                   end;
                  memo2.Visible:= true;
end;

procedure TForm1.Button3Click(Sender: TObject);
//Nos permite guardar en otro fichero los CA anteriormente extraidos
//Muy importante: se debe guardar en formato .pdb
begin
  begin

  if SaveDialog1.execute then
  memo2.lines.SaveToFile(SaveDialog1.FileName);
end;
end;

end.

