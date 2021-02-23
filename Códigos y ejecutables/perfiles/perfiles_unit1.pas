unit perfiles_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, biotools, math;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Delta: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1; p:TPDB;
  pdb:string;

  subfin, subini, resfin, resini, numresini, numresfin: integer;
  escalaH:string;
  h:TEscala;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  image1.canvas.clear;
  image2.canvas.clear;
  image3.canvas.clear;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  j:integer;
begin
  pdb:=CargarPDB(p);
  if pdb<>'' then
  begin
    edit1.text:=extractfilename(pdb);
    Combobox1.Clear;
    Combobox2.clear;
    for j:=1 to p.NumSubunidades do
    begin
     combobox1.Items.add(p.subs[j]);
     combobox2.Items.add(p.subs[j]);
     end;
     combobox1.itemindex:= 0;
     combobox2.itemindex:= p.NumSubunidades-1;

     numresini:= p.res[p.sub[1].res1].NumRes;
     numresfin:= p.res[p.sub[p.NumSubunidades].resn].NumRes;

     spinedit2.maxvalue:= p.res[p.sub[1].resn].NumRes;
     spinedit2.value:= numresini;

     spinedit3.maxvalue:= numresfin;
     spinedit3.value:= numresfin;
   end;
end;

procedure TForm1.Button1Click(Sender: TObject);

var
  datos: TTablaDatos;
  semiV: integer;
  sw, j, k, ndatos: integer;
  suma: real;
begin

  if (pdb<>'') and (escalaH<>'') then

  begin

    subini:= combobox1.ItemIndex +1;
    subfin:= combobox2.ItemIndex +1;
    numresini:= spinedit2.value;
    numresfin:= spinedit3.value;
    resini:= p.sub[subini].resindex[numresini];
    resfin:= p.sub[subfin].resindex[numresfin];
    setlength(datos, 2, resfin-resini+1);
    semiV:=spinedit1.value;
    if resfin<resini then
    begin
    sw:= resfin; resfin:= resini; resini:= sw;
    end;
    end;
    for j:= resini to resfin do
    begin
      suma:= 0; ndatos:=0;
      for k:=max(1,j-semiV) to min(j+semiV,p.NumResiduos) do
      begin
        suma:= suma + h[p.secuencia[k]];
        ndatos:= ndatos + 1;
      end;
      datos[0,j-resini]:=j;
      datos[1,j-resini]:= suma/ndatos;
    end;
    plotXY(datos, image1.canvas, 0, 1, true, true);
  end;


procedure TForm1.Button3Click(Sender: TObject);
begin
  escalaH:= CargarEscala(h);
  edit2.text:=extractFileName(escalaH);
end;

//Este botón permite calcular la anfipatía axial de los residuos
//seleccionados de una proteína siguiendo el algoritmo del momento de Eisenberg
procedure TForm1.Button4Click(Sender: TObject);
var
  datos: TTablaDatos;
  semiV: integer;
  sw, j, k, ndatos: integer;
  suma1, suma2, Delt: real;
begin

  if (pdb<>'') and (escalaH<>'') then

  begin

    subini:= combobox1.ItemIndex +1;
    subfin:= combobox2.ItemIndex +1;
    numresini:= spinedit2.value;
    numresfin:= spinedit3.value;
    resini:= p.sub[subini].resindex[numresini];
    resfin:= p.sub[subfin].resindex[numresfin];
    setlength(datos, 2, resfin-resini+1);
    semiV:=spinedit1.value;
    Delt:=spinedit4.value*pi/180;
    if resfin<resini then
    begin
    sw:= resfin; resfin:= resini; resini:= sw;
    end;
    end;
    for j:= resini to resfin do
    begin
      suma1:= 0; ndatos:=0; suma2:= 0;
      for k:=max(1,j-semiV) to min(j+semiV,p.NumResiduos) do
      begin
        suma1:= suma1 + h[p.secuencia[k]]*sin(Delt*k);
        suma2:= suma2 + h[p.secuencia[k]]*cos(Delt*k);
      end;
      datos[0,j-resini]:=j;
      datos[1,j-resini]:= sqrt(sqr(suma1)+sqr(suma2));
    end;
    plotXY(datos, image2.canvas, 0, 1, true, true);
  end;

//Este botón permite calcular la anfipatía axial de los residuos seleccionados
//de una proteína siguiendo el algoritmo de espectro de potencias de Fourier de Stroud
procedure TForm1.Button5Click(Sender: TObject);
var
  datos: TTablaDatos;
  semiV: integer;
  sw, j, k, ndatos: integer;
  suma, suma1, suma2, Delt, hmedia: real;
begin

  if (pdb<>'') and (escalaH<>'') then

  begin

    subini:= combobox1.ItemIndex +1;
    subfin:= combobox2.ItemIndex +1;
    numresini:= spinedit2.value;
    numresfin:= spinedit3.value;
    resini:= p.sub[subini].resindex[numresini];
    resfin:= p.sub[subfin].resindex[numresfin];
    setlength(datos, 2, resfin-resini+1);
    semiV:=spinedit1.value;
    Delt:=spinedit4.value*pi/180;
    if resfin<resini then
    begin
    sw:= resfin; resfin:= resini; resini:= sw;
    end;
    end;
    for j:= resini to resfin do
     begin
          suma:= 0; ndatos:=0;
      for k:=max(1,j-semiV) to min(j+semiV,p.NumResiduos) do
      begin
        suma:= suma + h[p.secuencia[k]];
        ndatos:= ndatos + 1;
      end;

    begin
      hmedia:=suma/ndatos;
      suma1:= 0; suma2:= 0;
      for k:=max(1,j-semiV) to min(j+semiV,p.NumResiduos) do
      begin
        suma1:= suma1 + (h[p.secuencia[k]]-hmedia)*sin(Delt*k);
        suma2:= suma2 + (h[p.secuencia[k]]-hmedia)*cos(Delt*k);
      end;
      datos[0,j-resini]:=j;
      datos[1,j-resini]:=sqr(suma1)+sqr(suma2);
    end;
    plotXY(datos, image3.canvas, 0, 1, true, true);
     end;
  end;

end.

