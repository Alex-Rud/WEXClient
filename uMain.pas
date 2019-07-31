unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.ListBox, FMX.Controls.Presentation, FMX.StdCtrls, FMXTee.Engine,
  FMXTee.Procs, FMXTee.Chart, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, FMX.ScrollBox, FMX.Memo, FMX.DateTimeCtrls, uPairs;

const
  CONST_TICKER = 'https://wex.nz/api/3/ticker/';

type
  TfrmMain = class(TForm)
    b1: TButton;
    cbTickers: TComboBox;
    idhttp1: TIdHTTP;
    mmoRawText: TMemo;
    b2: TButton;
    gb1: TGroupBox;
    lbl1: TLabel;
    edtLow: TEdit;
    edtAvg: TEdit;
    edtHigh: TEdit;
    lbl2: TLabel;
    edtVolume: TEdit;
    edtLast: TEdit;
    lbl3: TLabel;
    edtBuy: TEdit;
    edtSell: TEdit;
    tmdtUpdate: TTimeEdit;
    procedure b1Click(Sender: TObject);
    procedure b2Click(Sender: TObject);
  private
    procedure Get;
    procedure Parse(const AText: String);
    procedure ToForm(const APair: TPair);
  end;

var
  frmMain: TfrmMain;

implementation

uses
  JSON, DateUtils;

{$R *.fmx}

procedure TfrmMain.b1Click(Sender: TObject);
begin
  Get;
end;

procedure TfrmMain.b2Click(Sender: TObject);
begin
  ShowMessageUser(SysErrorMessage(GetLastError));
end;

procedure TfrmMain.Get;
 var
  s: String;
begin
  s := CONST_TICKER + cbTickers.Items[cbTickers.ItemIndex];
  s := idhttp1.Get(s);
  Parse(s);
end;

procedure TfrmMain.Parse(const AText: String);
 var
  js: TJSONArray;
  jo, joMonet: TJSONObject;
  ja: TJSONArray;
  jv: TJSONValue;

  pair: TPair;
  i, j:Integer;
  s: string;

  function GetValue(AIndex: Integer): Double;
  begin
    Result := StrToFloat(joMonet.Pairs[AIndex].JsonValue.ToString.Replace('.', ','));
  end;
begin
{
	"btc_usd":{
		"high":109.88,
		"low":91.14,
		"avg":100.51,
		"vol":1632898.2249,
		"vol_cur":16541.51969,
		"last":101.773,
		"buy":101.9,
		"sell":101.773,
		"updated":1370816308
	}

  s := '';
  try
    jo := TJSONObject.ParseJSONValue(AText) as TJSONObject;
    if Assigned(jo) then
    begin
      for i := 0 to jo.Size-1 do
      begin
        jv := jo.Pairs[i].JsonValue;

        joMonet := TJSONObject.ParseJSONValue(jv.ToString) as TJSONObject;
        if joMonet.Count <> 9 then
          raise Exception.Create('Некорректный ответ');

        pair.high     := GetValue(0);
        pair.low      := GetValue(1);
        pair.avg      := GetValue(2);
        pair.vol      := GetValue(3);
        pair.vol_cur  := GetValue(4);
        pair.last     := GetValue(5);
        pair.buy      := GetValue(6);
        pair.sell     := GetValue(7);
        pair.updated  := StrToInt(joMonet.Pairs[8].JsonValue.ToString);

        ToForm(pair);
      end;
    end else
      raise Exception.Create('Файл не содержит JSON-данные');
  except
    on E: Exception do
      s := E.Message;
  end;

  mmoRawText.Text := AText + #13 + s;
end;

procedure TfrmMain.ToForm(const APair: TPair);
begin
  edtLow.Text := FloatToStr(APair.low);
  edtHigh.Text := FloatToStr(APair.high);
  edtAvg.Text := FloatToStr(APair.avg);
  edtVolume.Text := Format('%f/%f', [APair.vol_cur, APair.vol]);
  edtLast.Text := FloatToStr(APair.last);
  edtBuy.Text := FloatToStr(APair.buy);
  edtSell.Text := FloatToStr(APair.sell);

  tmdtUpdate.Time := MSecsToTimeStamp(APair.updated).Time;
//  tmdtUpdate.DateTime := APair.updated//(SecsPerDay*1000);
end;

end.
