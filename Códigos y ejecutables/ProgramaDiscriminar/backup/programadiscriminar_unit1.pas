unit ProgramaDiscriminar_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, biotools;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1; formato:string; documento: TStrings; p:TPDB;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Opendialog1.execute then

  begin
    memo1.clear;
    memo1.lines.loadfromfile(OpenDialog1.FileName);
    edit1.Caption:=OpenDialog1.FileName;
    documento:= memo1.lines;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin     //Usando bucles if detectamos el formato del documento que cargamos en
  //el memo 1, y luego usamos la ecuación que tenemos en biotools para extraer la
  //la secuencia
   formato:='Formato no detectado';
  if (copy(documento[0],0,6)= 'HEADER')
   then formato:= 'PDB';

   if (copy(documento[0],0,2)='ID') and (copy(documento[1],0,2)='XX')
   then formato:= 'EMBL';

   if (copy(documento[0],0,2)='ID') and (copy(documento[1],0,2)='AC')
   then formato:= 'UniProt';

   if (copy(documento[0],0,5)='LOCUS')
   then formato:= 'GenBank';

   edit2.Caption:=formato;
   memo2.lines.clear;
   memo2.lines.add(CogerSecuencia(documento,formato));
end;

end.

