unit uFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.ExtCtrls,
  Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Mask, Vcl.Buttons, Vcl.Samples.Gauges;

type
  TFrmPrincipal = class(TForm)
    ConPrincipal: TFDConnection;
    Driver: TFDPhysPgDriverLink;
    qryPessoa: TFDQuery;
    dsqryPessoa: TDataSource;
    lblTitulo: TLabel;
    qryPessoaflnatureza: TSmallintField;
    qryPessoadsdocumento: TWideStringField;
    qryPessoanmprimeiro: TWideStringField;
    qryPessoanmsegundo: TWideStringField;
    qryPessoadtregistro: TDateField;
    qryPessoadscep: TWideStringField;
    qryPessoadsuf: TWideStringField;
    qryPessoanmcidade: TWideStringField;
    qryPessoanmbairro: TWideStringField;
    qryPessoanmlogradouro: TWideStringField;
    qryPessoadscomplemento: TWideStringField;
    qryPessoaidpessoa: TLargeintField;
    navPessoa: TDBNavigator;
    dbPrincipal: TDBGrid;
    qryAux: TFDQuery;
    qryPessoaidendereco: TLargeintField;
    qryPessoaidpessoa_1: TLargeintField;
    qryPessoaidendereco_1: TLargeintField;
    btLote: TSpeedButton;
    pnLote: TPanel;
    lblqtdLote: TLabel;
    gaugeLote: TGauge;
    lblTituloLote: TLabel;
    memlote: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure navPessoaClick(Sender: TObject; Button: TNavigateBtn);
    procedure dbPrincipalColEnter(Sender: TObject);
    procedure dbPrincipalKeyPress(Sender: TObject; var Key: Char);
    procedure qryPessoaAfterPost(DataSet: TDataSet);
    procedure btLoteClick(Sender: TObject);
    function SomenteNumero(Texto: string): string;
    function Preencher(Texto: String; Qtd: Integer; Com: String = ' '; Posicao: String = 'D'): String;
    function TransformarTextoEmLista(ATexto: string; const ADelimitador: Char) : TStringList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation


{$R *.dfm}

uses model.CEP;

procedure TFrmPrincipal.dbPrincipalColEnter(Sender: TObject);
begin
  if dbPrincipal.SelectedIndex = 0 then
    dbPrincipal.SelectedIndex := 1;
  if (dbPrincipal.SelectedIndex = 4) or (dbPrincipal.SelectedIndex > 5)then
    dbPrincipal.SelectedIndex := 5;
end;

procedure TFrmPrincipal.dbPrincipalKeyPress(Sender: TObject; var Key: Char);
var sCEP : String;
    Endereco: TStringList;
    EnderecoApi : TEnderecoApi;
begin
  case dbPrincipal.SelectedIndex of
    1 : begin
        if KEY = #13 then
        begin
          if qryPessoanmprimeiro.AsString = '' then
          begin
            showmessage('Por favor digite o primeiro nome');
            abort;
          end;
          dbPrincipal.SelectedIndex := 2;
        end;
    end;
    2 : begin
        if KEY = #13 then
        begin
          if qryPessoanmsegundo.AsString = '' then
          begin
            showmessage('Por favor digite o sobrenome');
            abort;
          end;
          dbPrincipal.SelectedIndex := 3;
        end;
    end;
    3 : begin
        if KEY = #13 then
        begin
          if qryPessoadsdocumento.AsString = '' then
          begin
            showmessage('Por favor digite o documento');
            abort;
          end;
          dbPrincipal.SelectedIndex := 5;
        end;
    end;
    5 : begin
        if KEY = #13 then
        begin
          sCEP := SomenteNumero(qryPessoadscep.Text);
          if Length(trim(sCEP)) <> 8 then
          begin
            Showmessage('CEP inv�lido.');
            dbPrincipal.SelectedIndex := 5;
            abort;
          end;
          EnderecoApi := TEnderecoApi.Create;
          BuscarCEP(sCEP, EnderecoApi);
          qryPessoanmlogradouro.AsString := EnderecoApi.Logradouro;
          qryPessoadscomplemento.AsString := EnderecoApi.Complemento;
          qryPessoanmBairro.AsString := EnderecoApi.Bairro;
          qryPessoanmcidade.AsString := EnderecoApi.Localidade;
          qryPessoadsuf.AsString := EnderecoApi.UF;
          FreeAndNil(EnderecoApi);
          dbPrincipal.SelectedIndex := 5;
        end;
    end;
  end;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  Driver.VendorHome := ExtractFilePath(Application.ExeName);
  qryPessoa.Open;
end;

procedure TFrmPrincipal.navPessoaClick(Sender: TObject; Button: TNavigateBtn);
begin
 if Button = nbInsert then
 begin
   with qryAux do
   begin
     close; sql.clear;
     sql.add('select max(idpessoa) as Seq from pessoa ');
     Prepare;
     open;
     if FieldByName('Seq').Text = '' then
       qryPessoaidpessoa.AsInteger := 1
     else
       qryPessoaidpessoa.AsInteger := FieldByName('Seq').AsInteger+1;
     qryPessoaidpessoa_1.AsInteger := qryPessoaidpessoa.AsInteger;
     qryPessoaidendereco.AsInteger := qryPessoaidpessoa.AsInteger;
     qryPessoaidendereco_1.AsInteger := qryPessoaidpessoa.AsInteger;
     qryPessoadtregistro.AsDateTime := now();

     qryPessoaflnatureza.AsInteger := 1;
     dbPrincipal.SetFocus;
     dbPrincipal.SelectedIndex := 1;
     close; sql.clear;
   end;
 end;
end;

procedure TFrmPrincipal.qryPessoaAfterPost(DataSet: TDataSet);
begin
  with qryAux do
  begin
    close; sql.clear;
    sql.add('select * from pessoa where idpessoa = :id ');
    parambyname('id').AsInteger :=  qryPessoaidpessoa.AsInteger;
    Prepare;
    open;
    if isempty then
    begin
      close; sql.Clear;
      sql.Add('insert into pessoa values (:id, :natureza, :documento, :nome, :sobrenome, :data) ');
      Parambyname('id').AsInteger := qryPessoaidpessoa.AsInteger;
      Parambyname('natureza').AsInteger := qryPessoaflnatureza.AsInteger;
      Parambyname('documento').AsString := qryPessoadsdocumento.AsString;
      Parambyname('nome').AsString := qryPessoanmprimeiro.AsString;
      Parambyname('sobrenome').AsString := qryPessoanmsegundo.AsString;
      Parambyname('data').AsDateTime := qryPessoadtregistro.AsDateTime;
      prepare;
      ExecSql;
    end;
    close; sql.clear;
    sql.add('select * from endereco where idpessoa = :id ');
    parambyname('id').AsInteger :=  qryPessoaidpessoa.AsInteger;
    Prepare;
    open;
    if isempty then
    begin
      close; sql.Clear;
      sql.Add('insert into endereco values (:id, :idpessoa, :cep) ');
      Parambyname('id').AsInteger := qryPessoaidpessoa.AsInteger;
      Parambyname('idpessoa').AsInteger := qryPessoaidpessoa.AsInteger;
      Parambyname('cep').AsString := qryPessoadscep.AsString;
      prepare;
      ExecSql;
    end;
    close; sql.clear;
    sql.add('select * from endereco_integracao where idendereco = :id');
    parambyname('id').AsInteger :=  qryPessoaidendereco.AsInteger;
    Prepare;
    open;
    if isempty then
    begin
      close; sql.Clear;
      sql.Add('insert into endereco_integracao values (:id, :uf, :cidade, :bairro, :logradouro, :complemento) ');
      Parambyname('id').AsInteger := qryPessoaidpessoa.AsInteger;
      Parambyname('uf').AsString := qryPessoadsuf.AsString;
      Parambyname('cidade').AsString := qryPessoanmcidade.AsString;
      Parambyname('bairro').AsString := qryPessoanmbairro.AsString;
      Parambyname('logradouro').AsString := qryPessoadsuf.AsString;
      Parambyname('complemento').AsString := qryPessoadsuf.AsString;
      prepare;
      ExecSql;
    end;
    close; sql.clear;
  end;
end;

procedure TFrmPrincipal.btLoteClick(Sender: TObject);
var xi, max : integer;
    Dados : TStringList;
    EnderecoApi : TEnderecoApi;
    ArquivoLote: TextFile;
    Linha : String;
begin
  if MessageDlg('Este procedimento vai incluir 50000 novos registros no banco de dados!'+#13+
                'Pode ser que demore um pouco.'+#13+
                'Deseja continuar?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if not FileExists(ExtractFilePath(Application.ExeName)+'Lote.txt') then
    begin
      showmessage('Arquivo Lote.txt deve estar no diret�rio do execut�vel!');
      abort;
    end
    else
    begin
      pnLote.Visible := True;
      lblqtdlote.Caption := 'Lendo arquivo Lote.txt...';
      memlote.Align := alClient;
      memlote.Visible := true;

      AssignFile(ArquivoLote, ExtractFilePath(Application.ExeName)+'Lote.txt');
      Reset(ArquivoLote);
      while (not eof(ArquivoLote)) do
      begin
        Application.ProcessMessages;
        readln(ArquivoLote, linha);
        if trim(linha) <> '' then
           memLote.Lines.Add(linha);
      end;
      CloseFile(ArquivoLote);
      memlote.Visible := False;
    end;
    with qryAux do
    begin
      close; sql.clear;
      sql.add('select max(idpessoa) as Seq from pessoa ');
      Prepare;
      open;
      if FieldByName('Seq').Text = '' then
        max := 1
      else
        max := FieldByName('Seq').AsInteger+1;
      close;
      sql.Clear;
    end;
    Dados :=  TStringList.Create;
    pnLote.Visible := True;
    lblqtdLote.Caption := '';
    gaugeLote.MaxValue := memLote.Lines.Count;
    gaugeLote.Progress := 0;
    qryPessoa.Close;
    for xi := 0 to memLote.Lines.Count do
    begin
      lblqtdLote.Caption := IntToStr(xi+1)+' de '+IntToStr(memLote.Lines.Count);
      gaugeLote.Progress := gaugeLote.Progress+1;
      gaugeLote.Refresh;
      Application.ProcessMessages;
      Dados.Clear;
      Dados := TransformarTextoEmLista( memLote.Lines[xi] ,'#');
{
2#dsdocumento50000#nmprimeiro50000#nmsegundo50000#14/09/2022#30350980
0 1                2               3              4          5
}
      if trim(Dados[0]) <> '' then
      begin
        with qryAux do
        begin
          close; sql.Clear;
          sql.Add('insert into pessoa values (:id, :natureza, :documento, :nome, :sobrenome, :data) ');
          Parambyname('id').AsInteger := max;
          Parambyname('natureza').AsInteger := StrToInt(Dados[0]);
          Parambyname('documento').AsString := Dados[1];
          Parambyname('nome').AsString := Dados[2];
          Parambyname('sobrenome').AsString := Dados[3];
          Parambyname('data').AsDateTime := now();
          prepare;
          ExecSql;

          close; sql.Clear;
          sql.Add('insert into endereco values (:id, :idpessoa, :cep) ');
          Parambyname('id').AsInteger := max;
          Parambyname('idpessoa').AsInteger := max;
          Parambyname('cep').AsString := Dados[5];
          prepare;
          ExecSql;

          close; sql.Clear;
          try
            sql.Add('insert into endereco_integracao values (:id, :uf, :cidade, :bairro, :logradouro, :complemento) ');

            EnderecoApi := TEnderecoApi.Create;
            BuscarCEP(Dados[5], EnderecoApi);

            Parambyname('id').AsInteger := max;
            Parambyname('uf').AsString :=  EnderecoApi.UF;
            Parambyname('cidade').AsString := EnderecoApi.Localidade;
            Parambyname('bairro').AsString := EnderecoApi.Bairro;
            Parambyname('logradouro').AsString := EnderecoApi.Logradouro;
            Parambyname('complemento').AsString := EnderecoApi.Complemento;

            FreeAndNil(EnderecoApi);
            prepare;
            ExecSql;
          except
          end;
          close; sql.Clear;
        end;
      end;
      max := max + 1;
    end;
  end;
  memLote.Lines.Clear;
  qryPessoa.Open;
  FreeAndNil(Dados);
  ShowMessage('Registros incluidos com sucesso!');
  pnLote.Visible := False;
  pnLote.Visible := False;
end;

function TFrmPrincipal.SomenteNumero(Texto: string): string;
var
  i  : Integer;
  Aux: string;
begin
  Aux   := '';
  for i := 1 to Length(Texto) do
  begin
    if CharInSet(Texto[i], ['0' .. '9']) then
      Aux := Aux + Texto[i];
  end;
  Result := Aux;
end;

function TFrmPrincipal.Preencher(Texto: String; Qtd: Integer; Com: String = ' '; Posicao: String = 'D'): String;
var
  Tam, i: Integer;
  Aux   : String;
begin
  if Length(Texto) = 0 then
    Tam := Qtd
  else
    Tam := Qtd - Length(Texto);

  if Length(Texto) >= Qtd then
    Result := Copy(Texto, 1, Qtd)
  else
  begin
    Aux   := Texto;
    for i := 1 to Tam do
    begin
      if Posicao = 'D' then
        Aux := Aux + Com
      else
        Aux := Com + Aux;
    end;
    Result := Aux;
  end;
end;

function TFrmPrincipal.TransformarTextoEmLista(ATexto: string; const ADelimitador: Char)  : TStringList;
var
  lStrItem: string;
begin
  result := TStringList.Create;
  if Length(ATexto) = 0 then
    Exit;
  ATexto := Trim(ATexto) + ADelimitador;
  while ATexto <> '' do
  begin
    lStrItem := Trim(Copy(ATexto, 1, pos(ADelimitador, ATexto) - 1));
    ATexto := Copy(ATexto, pos(ADelimitador, ATexto) + 1, Length(ATexto));
    result.Add(lStrItem);
  end;
end;

end.
