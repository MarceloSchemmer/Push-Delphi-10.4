unit uFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,FMX.Platform,

  {$IFDEF ANDROID}
  FMX.PushNotification.Android,
  {$ENDIF}
  {$IFDEF IOS}
  FMX.PushNotification.FCM.iOS,
  {$ENDIF}

  System.PushNotification, System.Notification;

type
  TFrmPrincipal = class(TForm)
    MemoLog: TMemo;
    NotificationCenter: TNotificationCenter;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    FPushService          : TPushService;
    FPushServiceConnection: TPushServiceConnection;

    //#-> Sempre que tiver mudan?a na conexao...
    procedure OnServiceConnectionChange(Sender: TObject;PushChanges: TPushService.TChanges);
    //#-> Registrar token no servidor...
    procedure RegistrarDevice(sToken: String);
    //#-> Ao receber punsh...
    procedure OnServiceConnectionReceiveNotification(Sender: TObject;const ServiceNotification: TPushServiceNotification);
    //#-> Obtendo dados ao clicar no push...
    function  AppEventProc(AAppEvent: TApplicationEvent;AContext: TObject): Boolean;

    procedure LimparNotificacoes();
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

function TFrmPrincipal.AppEventProc(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
    if (AAppEvent = TApplicationEvent.BecameActive) then
        LimparNotificacoes;
end;

procedure TFrmPrincipal.FormActivate(Sender: TObject);
var
    Notifications : TArray<TPushServiceNotification>;
    x : integer;
    msg : string;
begin
    Notifications := FPushService.StartupNotifications; // notificacoes que abriram meu app...

    if Length(Notifications) > 0 then
    begin
        for x := 0 to Notifications[0].DataObject.Count - 1 do
        begin
            MemoLog.lines.Add(Notifications[0].DataObject.Pairs[x].JsonString.Value + ' = ' +
                              Notifications[0].DataObject.Pairs[x].JsonValue.Value);

            if Notifications[0].DataObject.Pairs[x].JsonString.Value = 'mensagem' then
                msg := Notifications[0].DataObject.Pairs[x].JsonValue.Value;
        end;
    end;

    if msg <> '' then
        showmessage(msg);
end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    FPushServiceConnection.Free;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
var
    AppEvent : IFMXApplicationEventService;
begin
    // Eventos do app (para exclusao das notificacoes)...
    if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(AppEvent)) then
        AppEvent.SetApplicationEventHandler(AppEventProc);

    FPushService := TPushServiceManager.Instance.GetServiceByName(TPushService.TServiceNames.FCM);
    FPushServiceConnection := TPushServiceConnection.Create(FPushService);

    FPushServiceConnection.OnChange := OnServiceConnectionChange;
    FPushServiceConnection.OnReceiveNotification := OnServiceConnectionReceiveNotification;

    FPushServiceConnection.Active := True;
end;

procedure TFrmPrincipal.LimparNotificacoes;
begin
 NotificationCenter.CancelAll;
end;

procedure TFrmPrincipal.OnServiceConnectionChange(Sender: TObject;
  PushChanges: TPushService.TChanges);
var
    token : string;
begin
    if TPushService.TChange.Status in PushChanges then
    begin
        if FPushService.Status = TPushService.TStatus.Started then
        begin
            MemoLog.Lines.Add('Servi?o de push iniciado com sucesso');
            MemoLog.Lines.Add('----');
        end
        else
        if FPushService.Status = TPushService.TStatus.StartupError then
        begin
            FPushServiceConnection.Active := False;

            MemoLog.Lines.Add('Erro ao iniciar servi?o de push');
            MemoLog.Lines.Add(FPushService.StartupError);
            MemoLog.Lines.Add('----');
        end;
    end;

    if TPushService.TChange.DeviceToken in PushChanges then
    begin
        token := FPushService.DeviceTokenValue[TPushService.TDeviceTokenNames.DeviceToken];

        MemoLog.Lines.Add('Token do aparelho recebido');
        MemoLog.Lines.Add('Token: ' + token);
        MemoLog.Lines.Add('---');
        MemoLog.Lines.EndUpdate;

        RegistrarDevice(token);
    end;
end;

procedure TFrmPrincipal.OnServiceConnectionReceiveNotification(Sender: TObject;
  const ServiceNotification: TPushServiceNotification);
var
    x : integer;
    msg : string;
begin
    MemoLog.Lines.Add('Push recebido');
    MemoLog.Lines.Add('DataKey: ' + ServiceNotification.DataKey);
    MemoLog.Lines.Add('Json: ' + ServiceNotification.Json.ToString);
    MemoLog.Lines.Add('DataObject: ' + ServiceNotification.DataObject.ToString);
    MemoLog.Lines.Add('---');

    {
    for x := 0 to ServiceNotification.DataObject.Count - 1 do
    begin
        memLog.lines.Add(ServiceNotification.DataObject.Pairs[x].JsonString.Value + ' = ' +
                         ServiceNotification.DataObject.Pairs[x].JsonValue.Value);

        if ServiceNotification.DataObject.Pairs[x].JsonString.Value = 'mensagem' then
                msg := ServiceNotification.DataObject.Pairs[x].JsonValue.Value;
    end;

    if msg <> '' then
        showmessage(msg);
    }
end;

procedure TFrmPrincipal.RegistrarDevice(sToken:String);
begin
  //Salva o token do aparelho no servidor...
end;

end.
