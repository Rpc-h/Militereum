unit lowDexScore;

interface

uses
  // Delphi
  System.Classes,
  System.SysUtils,
  // FireMonkey
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  // web3
  web3,
  // project
  base,
  transaction;

type
  TFrmLowDexScore = class(TFrmBase)
    lblTitle: TLabel;
    lblTokenText: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure lblTokenTextClick(Sender: TObject);
  strict private
    procedure SetAction(value: TTokenAction);
    procedure SetToken(value: TAddress);
  public
    property Action: TTokenAction write SetAction;
    property Token: TAddress write SetToken;
  end;

procedure show(const action: TTokenAction; const chain: TChain; const tx: transaction.ITransaction; const token: TAddress; const callback: TProc<Boolean>; const log: TLog);

implementation

uses
  // project
  cache,
  common,
  thread;

{$R *.fmx}

procedure show(const action: TTokenAction; const chain: TChain; const tx: transaction.ITransaction; const token: TAddress; const callback: TProc<Boolean>; const log: TLog);
begin
  const frmLowDexScore = TFrmLowDexScore.Create(chain, tx, callback, log);
  frmLowDexScore.Action := action;
  frmLowDexScore.Token  := token;
  frmLowDexScore.Show;
end;

{ TFrmLowDexScore }

procedure TFrmLowDexScore.SetAction(value: TTokenAction);
begin
  lblTitle.Text := System.SysUtils.Format(lblTitle.Text, [ActionText[value]]);
end;

procedure TFrmLowDexScore.SetToken(value: TAddress);
begin
  lblTokenText.Text := string(value);
  cache.getFriendlyName(Self.Chain, value, procedure(friendly: string; err: IError)
  begin
    if Assigned(err) then Self.Log(err) else thread.synchronize(procedure
    begin
      lblTokenText.Text := friendly;
    end);
  end);
end;

procedure TFrmLowDexScore.lblTokenTextClick(Sender: TObject);
begin
  cache.fromName(lblTokenText.Text, procedure(address: TAddress; err: IError)
  begin
    if not Assigned(err) then
      common.Open(Self.Chain.Explorer + '/token/' + string(address))
    else
      common.Open(Self.Chain.Explorer + '/token/' + lblTokenText.Text);
  end);
end;

end.
