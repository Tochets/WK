unit model.CEP;
interface
uses
  System.JSON, System.Classes, REST.Client, System.SysUtils;

type
  TEnderecoApi = class
    public
      Logradouro  : String;
      Complemento : String;
      Bairro      : String;
      Localidade  : String;
      UF          : String;
      IBGE        : String;
      GIA         : String;
      DDD         : String;
      SIAFI       : String;
  end;

  procedure BuscarCEP(sCEP: string; xTipo : TEnderecoApi);


implementation

procedure BuscarCEP(sCEP: string; xTipo : TEnderecoApi);
var
  RESTClient1: TRESTClient;
  RESTRequest1: TRESTRequest;
  RESTResponse1: TRESTResponse;
  data: TJSONObject;
  Endereco : TEnderecoApi;
begin
  RESTClient1 := TRESTClient.Create(nil);
  RESTRequest1 := TRESTRequest.Create(nil);
  RESTResponse1 := TRESTResponse.Create(nil);
  RESTRequest1.Client := RESTClient1;
  RESTRequest1.Response := RESTResponse1;
  RESTClient1.BaseURL := 'https://viacep.com.br/ws/' + sCEP + '/json';
  RESTRequest1.Timeout := 100000;
  RESTRequest1.Execute;
  data := RESTResponse1.JSONValue as TJSONObject;
  try
    if Assigned(data) then
    begin
      try xTipo.Logradouro := data.Values['logradouro'].Value; except xTipo.Logradouro := ''; end;
      try xTipo.Complemento:= data.Values['complemento'].Value;except xTipo.Complemento := '';end;
      try xTipo.Bairro     := data.Values['bairro'].Value;     except xTipo.Bairro := '';     end;
      try xTipo.Localidade := data.Values['localidade'].Value; except xTipo.Localidade := ''; end;
      try xTipo.UF         := data.Values['uf'].Value;         except xTipo.UF := '';         end;
      try xTipo.IBGE       := data.Values['ibge'].Value;       except xTipo.IBGE := '';       end;
      try xTipo.GIA        := data.Values['gia'].Value;        except xTipo.GIA := '';        end;
      try xTipo.DDD        := data.Values['ddd'].Value;        except xTipo.DDD := '';        end;
      try xTipo.SIAFI      := data.Values['siafi'].Value;      except xTipo.SIAFI := '';      end;
    end;
  except
  end;
  FreeAndNil(data);
end;

end.
