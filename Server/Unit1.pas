unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  JSON,
  system.net.httpclient

  ;

type
  TForm1 = class(TForm)
    edt_msg: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
        client : THTTPClient;
        v_json : TJSONObject;
        v_jsondata : TJSONObject;
        v_data : TStringStream;
        v_response : TStringStream;
        //-------
        token_celular : string;
        codigo_projeto : string;
        api : string;
        url_google : string;
begin
        try
                url_google := 'https://fcm.googleapis.com/fcm/send'; // Firebase
                token_celular := 'dpilmCPCDfk:APA91bFDnwILy-umCfKVDozaS2cIRnyag4SbeQB-IkZZuFlQ424YE_bTLjdLBwpT6Nao1XSOFDfYOTD-wXUIf3axVdJHwCBIH9VDSPJ-THVU8wJ4Ziy2cRS-n5VFmcJcerGiWTZ6cDDx'; // Token do celular...
                codigo_projeto := '1020526764190'; // Coloque o codigo do seu projeto...
                api := 'AAAA7ZwioJ4:APA91bFmHgAPdkmy9gAnOn0wm0xB46tklBybyA1i-B7k2X5JvIWpX0ZZpE9kCyfvGeqZL__tvqyr7zB1Jz8OewaDdPA_SUoKl4tEHSdSorX-0cO2GiiwblLO3mwNCKdIcOHc1klVb_Gl';  // Coloque sua API...

                //--------------------------------

                v_json := TJSONObject.Create;
                v_json.AddPair('to', token_celular);

                v_jsondata := TJSONObject.Create;
                v_jsondata.AddPair('body', edt_msg.Text);

                v_json.AddPair('notification', v_jsondata);


                v_jsondata := TJSONObject.Create;
                v_jsondata.AddPair('mensagem', edt_msg.Text);
                v_jsondata.AddPair('campo_extra', '12345');

                v_json.AddPair('data', v_jsondata);


                client := THTTPClient.Create;
                client.ContentType := 'application/json';
                client.CustomHeaders['Authorization'] := 'key=' + api;

                memo1.Lines.Add('JSON ENVIO ---------------------');
                memo1.Lines.Add(v_json.ToString);
                memo1.Lines.Add('');

                v_data := TStringStream.Create(v_json.ToString, TEncoding.UTF8);
                V_data.Position := 0;

                v_response := TStringStream.Create;

                client.Post(url_google, v_data, v_response);
                v_response.Position := 0;

                memo1.Lines.Add('RETORNO ---------------------');
                memo1.Lines.Add(v_response.DataString);
                memo1.Lines.Add('');

        except on e:exception do
                showmessage('Erro: ' + e.Message);
        end;

end;

end.
