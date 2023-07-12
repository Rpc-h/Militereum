unit airdrop;

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
  base;

type
  TFrmAirdrop = class(TFrmBase)
    lblTitle: TLabel;
    lblTokenText: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure lblTokenTextClick(Sender: TObject);
  strict private
    FChain: TChain;
    procedure SetAction(value: TTokenAction);
    procedure SetToken(value: TAddress);
  public
    property Action: TTokenAction write SetAction;
    property Chain: TChain write FChain;
    property Token: TAddress write SetToken;
  end;

procedure show(const action: TTokenAction; const chain: TChain; const token: TAddress; const callback: TProc<Boolean>);

implementation

uses
  // FireMonkey
  FMX.Forms,
  // web3
  web3.eth.types,
  // project
  common,
  thread;

{$R *.fmx}

procedure show(const action: TTokenAction; const chain: TChain; const token: TAddress; const callback: TProc<Boolean>);
begin
  const frmAirdrop = TFrmAirdrop.Create(Application);
  frmAirdrop.Action   := action;
  frmAirdrop.Chain    := chain;
  frmAirdrop.Token    := token;
  frmAirdrop.Callback := callback;
  frmAirdrop.Show;
end;

{ TFrmAirdrop }

procedure TFrmAirdrop.SetAction(value: TTokenAction);
begin
  thread.synchronize(procedure
  begin
    lblTitle.Text := System.SysUtils.Format(lblTitle.Text, [ActionText[value]]);
  end);
end;

procedure TFrmAirdrop.SetToken(value: TAddress);
begin
  lblTokenText.Text := string(value);
  value.ToString(TWeb3.Create(common.Ethereum), procedure(ens: string; err: IError)
  begin
    if not Assigned(err) then
      thread.synchronize(procedure
      begin
        lblTokenText.Text := ens;
      end);
  end);
end;

procedure TFrmAirdrop.lblTokenTextClick(Sender: TObject);
begin
  TAddress.FromName(TWeb3.Create(common.Ethereum), lblTokenText.Text, procedure(address: TAddress; err: IError)
  begin
    if not Assigned(err) then
      common.Open(Self.FChain.Explorer + '/token/' + string(address))
    else
      common.Open(Self.FChain.Explorer + '/token/' + lblTokenText.Text);
  end);
end;

end.
