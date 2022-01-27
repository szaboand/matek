{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+}
{$M 32768,0,655360}
Program Start;
{*****************************************************************************
******************************************************************************
*                            Matek 1.0 V1.02                                 *
*                        1998.03.05. - 1998.05.22.                           *
*                          Szab¢ Andr†s 1984-97                              *
*                           (C) TwinNet 1997                                 *
******************************************************************************
*****************************************************************************}

Uses TWSys,TObject,TObjects;

{****************************************************************************}
{***                             T°pusok                                  ***}
{****************************************************************************}

Type

 FuggvenyType = record
  Nev           : string[10];
  Kod           : byte;
 end;

 ValtozoTipus = record
  Nev           : string[10];
  Ertek         : real;
 end;

{****************************************************************************}
{***                              Konstansok                              ***}
{****************************************************************************}

Const
 VMode                 :  word    = _640x480_16;   { Vide¢m¢d k¢dja         }
 ProgramName :  string  = 'Matek V1.1 for DOS - (C) TwinNet 1998';
 MDVX                  :  word    = $0003;       { Mouse X oszt†sar†ny (SHR) }
 MDVY                  :  word    = $0003;       { Mouse X oszt†sar†ny (SHR) }
 PixRat                :  word    = $0001;       { Mouse Pixel/Ratio         }
 MouseAct              :  boolean = FALSE;        { Saj†t mouse megjelen°tÇs  }

 BackgroundColor       :  byte    = $07;           { H†ttÇrszin              }
 DBackgroundColor      :  byte    = $08;           { SîtÇt h†ttÇrszin        }
 LBackgroundColor      :  byte    = $0F;           { Vil†gos h†ttÇrszin      }
 PTextColor1           :  byte    = $0F;           { Picture szîvegszin      }
 PTextColor2           :  byte    = $08;           { Picture †rnyÇksin       }
 ProgramNameColor      :  byte    = $0a;           { ProgramnÇvszin          }
 ETextColor            :  byte    = $00;           { EredmÇnymegjelen°tãszin }
 ExpWBackColor         :  byte    = $00;           { EredmÇnyek ablak hszin  }
 ExpWTextColor         :  byte    = $0F;           { EredmÇnyek ablak tszin  }
 ErrTextColor          :  byte    = $04;           { Hibaszin                }
 TimeTextColor         :  byte    = $09;           { IdãkijelzÇs sz°n        }

 _SystemExitButtonCode            = $0001;         { Command k¢dok           }
 _OkButtonCode                    = $0002;
 _Ok2ButtonCode                   = $0003;
 _UjKepletButtonCode              = $0004;
 _CalcButtonCode                  = $0005;

 _SystemExitButtonString          = ' KilÇp ';     { Exit Button felirat     }
 _OkButtonString                  = '  OK  ';      { Ok Button felirat       }
 _Ok2ButtonString                 = 'V†ltoz¢k aktualiz†l†sa';
 _UjKepletButtonString            = ' Èj kÇplet ';
 _CalcButtonString                = ' Kalkul†tor ';

 EditX                 :  word    = 60;            { Edit ablak X koordin†ta }
 EditY                 :  word    = 100;           { Edit ablak Y koordin†ta }

 FuggvenyNum            = 11;
 Fuggveny     : array [1..FuggvenyNum] of FuggvenyType = ( (Nev:'SIN';Kod:1),
                                                           (Nev:'COS';Kod:2),
                                                           (Nev:'ABS';Kod:3),
                                                           (Nev:'SQR';Kod:4),
                                                           (Nev:'SQRT';Kod:5),
                                                           (Nev:'LN';Kod:6),
                                                           (Nev:'EXP';Kod:7),
                                                           (Nev:'ARCTAN';Kod:8),
                                                           (Nev:'INT';Kod:9),
                                                           (Nev:'FRAC';Kod:10),
                                                           (Nev:'RND';Kod:11)
                                                         );


 NagyBetuk : set of char = ['A'..'Z'];
 SzamJegyek: set of char = ['0'..'9'];
 Operator0 : set of char = ['+','-','*','-',#1..#11];
 Operator1 : set of char = ['*','/',#1..#11];
 Operator2 : set of char = [#1..#11];

 Err_No              = $00;
 Err_TizedesPont1    = $01;
 Err_TizedesPont2    = $02;
 Err_Operator1       = $03;
 Err_Syntax          = $04;
 Err_Operandus1      = $05;
 Err_Operandus2      = $06;
 Err_Operandus3      = $07;
 Err_NullaOsztas     = $08;
 Err_ValtozoHivat    = $09;
 Err_Zarojel         = $0A;
 Err_Valtozo         = $0B;

 Expression_Error    : array [0..11] of string = ( 'OK',
                                                  'Hibas tizedespont',
                                                  'Tiedespont utan bet˚',
                                                  'Operator hiba',
                                                  'êrtelmezhetetlen kifejezÇs',
                                                  'Operandus hiba',
                                                  'FÅggvÇny operandusa hi†nyzik',
                                                  'Negativ operandus',
                                                  'Null†val oszt†s',
                                                  'êrvÇnytelen v†ltoz¢hivatkoz†s',
                                                  'Hib†s z†r¢jelezÇs',
                                                  'Hib†s v†ltoz¢(k)'
                                                );

 MaxValtozoNum       = 100;

 VEditX              : word       = 5;
 VEditY              : word       = 40;
 Abr                 : byte       = 20;  { Kijelzett eredmÇny sz†mjegyek    }
 Decimal             : byte       = 8;   { Kijelzett eredmÇny tizedesjegyek }
 KExpNum             : byte       = 0;   { KiÇrtÇkelt kifejezÇsek sz†ma     }

 ExpressionPufferSize             = 15000;


{****************************************************************************}
{***                            Objektumok                                ***}
{****************************************************************************}

Type

 MyButtonType   = object(ButtonType)
  Procedure DoButton;virtual;
 end;

 MyEditType     = object(EditType)
  Procedure  ControlKey;virtual;
  Procedure  MouseFocusOn;virtual;
  Procedure  SetInit;virtual;
 end;

 MyTextType     = object(TextType)
  Procedure  SetInit;virtual;
 end;

 MyTimeType     = object(TextType)
  TF           : boolean;
  Procedure  SetInit;virtual;
  Procedure  Draw;virtual;
  Procedure  Timer;virtual;
 end;

{****************************************************************************}
{***                               V†ltoz¢k                               ***}
{****************************************************************************}

Var
 ExitButton           : MyButtonType;
 OkButton             : MyButtonType;
 Ok2Button            : MyButtonType;
 UjKepletButton       : MyButtonType;
 CalcButton           : MyButtonType;
 Expression           : MyEditType;
 ExpressionsText      : MyTextType;
 TimeText             : MyTimeType;

 CommandCode          : word;

 Valtozo              : array [1..MaxValtozoNum] of ValtozoTipus;
 ValtozoNum           : word;
 ValtozoEditW         : array [1..MaxValtozoNum] of MyEditType;

 ExpressionPuffer     : array [1..ExpressionPufferSize+1] of byte;
 EPMut                : word;

{****************************************************************************}
{***                    MyButtonType objektum met¢dusai                   ***}
{****************************************************************************}

Procedure MyButtonType.DoButton;
Begin
If BText=_SystemExitButtonString then CommandCode:=_SystemExitButtonCode;
If BText=_OkButtonString then CommandCode:=_OkButtonCode;
If BText=_Ok2ButtonString then CommandCode:=_Ok2ButtonCode;
If BText=_UjKepletButtonString then CommandCode:=_UjKepletButtonCode;
If BText=_CalcButtonString then CommandCode:=_CalcButtonCode;
End;

{****************************************************************************}
{***                      MyEditType objektum met¢dusai                   ***}
{****************************************************************************}

Procedure MyEditType.ControlKey;
Begin
Case ID of
     0 : If Command.KeyCode=28 then CommandCode:=_OkButtonCode;
     1 : begin end;
     else If Command.KeyCode=28 then CommandCode:=_Ok2ButtonCode;
     end;
End;

Procedure MyEditType.MouseFocusOn;
Begin
Inherited MouseFocusOn;
SetKeyFocus;
End;

Procedure MyEditType.SetInit;
Begin
If ID>0 then Chars:=Char8x8;
End;

{****************************************************************************}
{***                      MyTextType objektum met¢dusai                   ***}
{****************************************************************************}

Procedure MyTextType.SetInit;
Begin
BackColor:=ExpWBackColor;TextBackColor:=ExpWBackColor;TextColor:=ExpWTextColor;
Chars:=Char8x8;LineSpace:=3;
End;

{****************************************************************************}
{***                       MyTimeType objektum met¢dusai                  ***}
{****************************************************************************}

Procedure MyTimeType.SetInit;
Begin
Chars:=1;LineSpace:=1;DY:=CDY*(8+LineSpace);
TextColor:=TimeTextColor;TextBackColor:=BackGroundColor;
End;

Procedure MyTimeType.Draw;
var t:string;tt:^byte;
Begin
T:='HU-B '+GetTimeStr(0);
If TF then T:=T+' ' else T:=T+'.';TF:=Not(TF);
T:=GetDateStr(false)+chr(10)+T+chr(0);
TT:=@T;Inc(TT);TextPointer:=TT;
Inherited Draw;
End;

Procedure MyTimeType.Timer;
Begin
Draw;
End;

{****************************************************************************}
{***                      Be°rt kÇplet ellenãrzÇse                        ***}
{****************************************************************************}

Function Ellenoriz(fv:string;var HK:byte):word;
var i:word;ii:integer;op,p,sg:boolean;
Begin
i:=length(fv);
if fv[i] in Operator0 then begin HK:=Err_Operandus1;Ellenoriz:=i;Exit;end;
i:=1;ii:=0;HK:=0;op:=true;p:=false;sg:=false;
while (i<=length(fv)) and (HK=0) do
      begin
      Case (fv[i]) of
           'a'..'z','A'..'Z'   : begin
                                 if p then HK:=Err_TizedesPont2;op:=false;end;
           '0'..'9'            : op:=false;
           '.',','             : begin if p then HK:=Err_TizedesPont1;p:=true;end;
           '('                 : Inc(II);
           ')'                 : Dec(II);
           '*','/'             : begin if op then HK:=Err_Operator1;op:=true;p:=false;end;
           '+','-'             : begin
                                 If op and (i>1) and (not sg) then HK:=Err_Operator1;
                                 op:=true;p:=false;
                                 end;
           else HK:=Err_Syntax;
           end;
      if fv[i]='(' then sg:=true else sg:=false;
      inc(i);
      end;
If (II<>0) and (HK=0) then HK:=Err_Zarojel;
if HK=0 then i:=0;Ellenoriz:=i;
end;

{****************************************************************************}
{***            Be°rt kÇpletben fÅggvÇnyek  †talak°t†sa                   ***}
{****************************************************************************}

Function FuggvenyAlakit(fv:string):string;
var i,j:word;nfv,mi,mi1:string;ki:boolean;
Begin
i:=1;nfv:='';
while i<=length(fv) do
      begin
      mi:='';mi1:='';
      while (i<=length(fv)) and not ((upcase(fv[i]) in NagyBetuk))
            do begin nfv:=nfv+fv[i];inc(i);end;
      while (i<=length(fv)) and (upcase(fv[i]) in NagyBetuk)
            do begin mi:=mi+upcase(fv[i]);mi1:=mi1+(fv[i]);inc(i);end;
      j:=1;ki:=false;
      while (j<=FuggvenyNum) and (not ki) do
            If Fuggveny[j].Nev=mi then Ki:=true else inc(j);
      if (Ki) and (i<length(fv)) and (fv[i]='(')
         then nfv:=nfv+chr(Fuggveny[j].Kod) else nfv:=nfv+mi1;
      end;
FuggvenyAlakit:=NFV;
End;


{****************************************************************************}
{***                      Lengyel formul†v† alak°t†s                      ***}
{****************************************************************************}

Function LAtalakit(fv:string):string;
var i:word;mi,mi1:string;verem:array[1..500] of char;vm:byte;
    op,eh:boolean;
Begin
i:=1;mi1:='';mi:='';vm:=0;eh:=false;op:=true;
while i<=length(fv) do
      begin
      Case (fv[i]) of
           'a'..'z','A'..'Z'   : begin mi:=mi+fv[i];eh:=true;op:=false;end;
           '0'..'9'            : begin mi:=mi+fv[i];eh:=true;op:=false;end;
           '.'                 : begin mi:=mi+fv[i];eh:=true;end;
           ','                 : begin mi:=mi+'.';eh:=true;end;
           '('                 : begin
                                 if eh then begin mi:=mi+'_';eh:=false;end;
                                 inc(vm);verem[vm]:=fv[i];
                                 end;
           ')'                 : begin
                                 if eh then begin mi:=mi+'_';eh:=false;end;
                                 while verem[vm]<>'(' do
                                       begin mi:=mi+verem[vm]+'_';dec(vm);end;
                                 dec(vm);
                                 end;
           '*','/'             : begin
                                 if eh then begin mi:=mi+'_';eh:=false;end;
                                 while (vm>0) and ((verem[vm] in Operator1))
                                       do begin mi:=mi+verem[vm]+'_';dec(vm);end;
                                 inc(vm);verem[vm]:=fv[i];op:=true;
                                 end;
           '+','-'             : begin
                                 if op then begin mi:=mi+'0'+'_';op:=false;end;
                                 if eh then begin mi:=mi+'_';eh:=false;end;
                                 while (vm>0) and ((verem[vm] in Operator0))
                                       do begin mi:=mi+verem[vm]+'_';dec(vm);end;
                                 inc(vm);verem[vm]:=fv[i];op:=true;
                                 end;
           #1..#11              : begin
                                 if eh then begin mi:=mi+'_';eh:=false;end;
                                 while (vm>0) and ((verem[vm] in Operator2))
                                       do begin mi:=mi+verem[vm]+'_';dec(vm);end;
                                 inc(vm);verem[vm]:=fv[i];op:=true;
                                 end;
           end;
      inc(i);
      end;
if eh then mi:=mi+'_';
while vm>0 do begin mi:=mi+verem[vm]+'_';dec(vm);end;
LAtalakit:=mi;
End;

{****************************************************************************}
{***                     Lengyel formul†b¢l kiÇrtÇkelÇs                   ***}
{****************************************************************************}

Function KiSzamit(fv:string;var HK:byte):real;
var x:real;i,j:word;mi1:string;verem:array[1..500] of real;vm:byte;er:integer;
    van:boolean;
Begin
i:=1;vm:=0;HK:=0;j:=0;
while (i<=length(fv)) and (HK=0) do
      begin
      mi1:='';
      while (i<=length(fv)) and (fv[i]<>'_') do begin mi1:=mi1+fv[i];inc(i);end;
           If mi1='*' then if vm<2 then HK:=Err_Operandus1 else begin X:=verem[vm]*verem[vm-1];dec(vm);verem[vm]:=X;end
      else If mi1='+' then if vm<2 then HK:=Err_Operandus1 else begin X:=verem[vm]+verem[vm-1];dec(vm);verem[vm]:=X;end
      else If mi1='-' then if vm<2 then HK:=Err_Operandus1 else begin X:=verem[vm-1]-verem[vm];dec(vm);verem[vm]:=X;end
      else If mi1='/' then if vm<2 then HK:=Err_Operandus1 else begin
              if verem[vm]=0 then HK:=Err_NullaOsztas else X:=verem[vm-1]/verem[vm];dec(vm);verem[vm]:=X;end
      else If mi1=chr(1) then if vm<1 then HK:=Err_Operandus2 else begin X:=sin(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(2) then if vm<1 then HK:=Err_Operandus2 else begin X:=cos(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(3) then if vm<1 then HK:=Err_Operandus2 else begin X:=abs(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(4) then if vm<1 then HK:=Err_Operandus2 else begin X:=sqr(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(5) then if vm<1 then HK:=Err_Operandus2 else begin
              if verem[vm]<0 then HK:=Err_Operandus3 else X:=sqrt(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(6) then if vm<1 then HK:=Err_Operandus2 else begin X:=ln(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(7) then if vm<1 then HK:=Err_Operandus2 else begin X:=exp(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(8) then if vm<1 then HK:=Err_Operandus2 else begin X:=arctan(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(9) then if vm<1 then HK:=Err_Operandus2 else begin X:=int(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(10) then if vm<1 then HK:=Err_Operandus2 else begin X:=frac(verem[vm]);verem[vm]:=X;end
      else If mi1=chr(11) then if vm<1 then HK:=Err_Operandus2 else begin X:=random;verem[vm]:=X;end
      else begin
           val(mi1,x,er);
           if er<>0
              then begin
                   j:=1;van:=false;
                   while (j<=ValtozoNum) and (not van)
                    do If Valtozo[j].Nev=mi1 then Van:=true else inc(j);
                   If van then X:=Valtozo[J].Ertek else HK:=Err_ValtozoHivat;
                   end;
           inc(vm);Verem[vm]:=x;
           end;
      inc(i);
      end;
If vm=0 then HK:=Err_Syntax;
If HK=0 then KiSzamit:=Verem[vm] else Kiszamit:=0;
End;

{****************************************************************************}
{***                            Hiba megjelen°tÇse                        ***}
{****************************************************************************}

Procedure Hiba(HK:word);
var mi:string;Hkod:byte;
Begin
SetColor(BackgroundColor);
BAr(VEditX+10*9+110+3,VEditY+(GetMaxY-140)+3,VeditX+10*9+110+GetMaxX-215,VEditY+(GetMaxY-140)+20);
SetTextBackColor(BackgroundColor);SetColor(ErrTextColor);SetTextOver(1);
Rom_8x16;OutStringXY(VEditX+10*9+110+5+4,VEditY+(GetMaxY-140)+6,Expression_Error[HK]);
End;

{****************************************************************************}
{***                    EredmÇny besz£r†sa a pufferba                     ***}
{****************************************************************************}

Function ValtozoBehelyettesit(fv:string):string;
var i,j:byte;nfv,mi,mi2:string;ki:boolean;
Begin
i:=1;nfv:='';
while i<=length(fv) do
      begin
      mi:='';
      while (i<=length(fv)) and not ((upcase(fv[i]) in NagyBetuk))
            do begin nfv:=nfv+fv[i];inc(i);end;
      while (i<=length(fv)) and (upcase(fv[i]) in NagyBetuk)
            do begin mi:=mi+fv[i];inc(i);end;
      j:=1;ki:=false;
      while (j<=ValtozoNum) and (not ki) do
            If Valtozo[j].Nev=mi then Ki:=true else inc(j);
      if Ki
         then begin
              str(Valtozo[j].Ertek:abr:decimal,mi2);
              while mi2[1]=' ' do mi2:=Copy(mi2,2,length(mi2));
              while mi2[length(mi2)]='0' do mi2:=Copy(mi2,1,length(mi2)-1);
              if mi2[length(mi2)]='.' then mi2:=Copy(mi2,1,length(mi2)-1);
              nfv:=nfv+mi2;
              end
         else nfv:=nfv+mi;
      end;
Valtozobehelyettesit:=nfv;
End;

Procedure AddEredmenyPuffer(fv:string);
var i:word;
Begin
for i:=1 to length(fv) do
    If EpMut<=ExpressionPufferSize
       then begin
            ExpressionPuffer[EPMut]:=ord(fv[i]);
            Inc(EPMut);
            end;
If EpMut<ExpressionPufferSize
   then begin ExpressionPuffer[EPMut]:=EndOfLine;Inc(EPMut);end;
ExpressionPuffer[EPMut]:=EndOfText;Inc(KExpNum);
If KExpNum>ExpressionsText.CDY+ExpressionsText.EY then Inc(ExpressionsText.EY);
ExpressionsText.Show;
End;


{****************************************************************************}
{***                        EredmÇny megjelen°tÇse                        ***}
{****************************************************************************}

Procedure Eredmeny(mi1,fv,orgfv:string);
var mi,mi2:string;Hkod:byte;
Begin
Str(KiSzamit(fv,Hkod):Abr:Decimal,mi);
If Hkod<>0
   then Hiba(HKod)
   else begin
        while mi[1]=' ' do mi:=Copy(mi,2,length(mi));
        while mi[length(mi)]='0' do mi:=Copy(mi,1,length(mi)-1);
        If mi[length(mi)]='.' then mi:=Copy(mi,1,length(mi)-1);
        mi2:=ValtozoBehelyettesit(OrgFv)+'='+mi;
        AddEredmenyPuffer(mi2);
        SetColor(BackgroundColor);
        Bar(VEditX+10*9+110+3,VEditY+(GetMaxY-140)+3,VeditX+10*9+110+GetMaxX-215,VEditY+(GetMaxY-140)+20);
        SetTextBackColor(BackgroundColor);SetColor(ETextColor);SetTextOver(1);
        Rom_8x16;OutStringXY(VEditX+10*9+110+5,VEditY+(GetMaxY-140)+6,mi1+mi);
        end;
End;

{****************************************************************************}
{***                     FÅggvÇnykÇplet megjelen°tÇse                     ***}
{****************************************************************************}

Function FuggvenyKeplet:string;
var mi:string;i:word;
Begin
mi:='F(';
for i:=1 to ValtozoNum do mi:=mi+Valtozo[i].Nev+',';
if mi[length(mi)]=',' then mi[length(mi)]:=')' else mi:=mi+')';
mi:=mi+'=';FuggvenyKeplet:=mi;
End;

{****************************************************************************}
{***                         V†ltoz¢k ÇrtÇkad†sa                          ***}
{****************************************************************************}

Procedure VErtekAd(fv:string);
var i,j:word;mi,mi1:string;van:boolean;
Begin
i:=1;ValtozoNum:=0;
while i<=length(fv) do
      begin
      mi:='';
      while (i<=length(fv)) and not ((upcase(fv[i]) in NagyBetuk)) do inc(i);
      while (i<=length(fv)) and ((upcase(fv[i]) in NagyBetuk) or (fv[i] in Szamjegyek))
            do begin mi:=mi+fv[i];inc(i);end;
      if mi<>''
         then begin
              j:=1;van:=false;
              while (j<=ValtozoNum) and (not van)
                    do If Valtozo[j].Nev=mi then Van:=true else inc(j);
              If not van
                 then begin
                      Inc(ValtozoNum);
                      Valtozo[ValtozoNum].Nev:=mi;Valtozo[ValtozoNum].Ertek:=1;
                      end;
              end;
      end;
End;

{****************************************************************************}
{***                     V†ltoz¢k ÇrtÇkad†sa rutin                        ***}
{****************************************************************************}

Procedure VErtek_Init;
var i,max:word;mi:string;
Begin
max:=0;
for i:=1 to ValtozoNum do If length(Valtozo[i].nev)>max then max:=length(Valtozo[i].nev);
for i:=1 to ValtozoNum
    do begin
       mi:=Valtozo[i].Nev;while length(mi)<Max do mi:=' '+mi;
       SetTextBackColor(BackgroundColor);SetColor(ETextColor);SetTextOver(1);
       Rom_8x8;OutStringXY(VEditX+8,VEditY+(i-1)*19+4+40,mi+':');
       ValtozoEditW[i].Init(I+1,VEditX+8+(Max+1)*8,VEditY+(i-1)*19+40,10,'1');
       end;
End;

Procedure VErtek_Done;
var i:word;
Begin
for i:=ValtozoNum downto 1 do ValtozoEditW[i].Done;
End;

Procedure VErtek_Main(mi1,fv,ofv:string);
var C:CommandType;i:word;X:real;err:integer;omi,mi:string;
Begin
Expression.Off;OkButton.Off;
VErtek_Init;Ok2Button.On;UjKepletButton.On;
SetColor(BackgroundColor);
BAr(VEditX+10*9+110+3,VEditY+(GetMaxY-140)+3,VeditX+10*9+110+GetMaxX-215,VEditY+(GetMaxY-140)+20);
SetTextBackColor(BackgroundColor);SetColor(ETextColor);SetTextOver(1);
Rom_8x16;OutStringXY(VEditX+10*9+110+5,VEditY+(GetMaxY-140)+6,mi1);
ClearCommandPuffer;ValtozoEditW[1].SetKeyFocus;
repeat
      CommandCode:=0;SetMouseFocus;
      repeat
            If GetCommand(C)<>0 then TObjectProcess(C);
      until CommandCode<>0;
      Case CommandCode of
           _Ok2ButtonCode : begin
                            SetColor(BackGroundColor);
                            BAr(VEditX+10*9+110+5+length(mi1)*8+4,VEditY+(GetMaxY-140)+3,
                                VeditX+10*9+110+GetMaxX-215,VEditY+(GetMaxY-140)+20);
                            for i:=1 to ValtozoNum
                                do begin
                                   Mi:=ValtozoEditW[i].EditText;
                                   Mi:=Copy(mi,1,length(mi)-1);
                                   Val(mi,x,err);
                                   if err<>0
                                      then CommandCode:=0
                                      else Valtozo[i].Ertek:=X;
                                   end;
                            if CommandCode<>0
                               then Eredmeny(mi1,Fv,ofv) else Hiba(Err_Valtozo);
                            end;
           end;
until (CommandCode=_SystemExitButtonCode) or (CommandCode=_UjKepletButtonCode);
UjKepletButton.Off;Ok2Button.Off;VErtek_Done;
OkButton.On;Expression.On;
SetColor(BackgroundColor);
Bar(VEditX+3,VEditY+23,VEditX+10*9+101,VEditY+GetMaxY-120);
BAr(VEditX+10*9+110+3,VEditY+(GetMaxY-140)+3,VeditX+10*9+110+GetMaxX-215,VEditY+(GetMaxY-140)+20);
End;

{****************************************************************************}
{***                               Fãprogram                              ***}
{****************************************************************************}

Procedure Kiertekeles(OrgFv:string);
var I:word;Hkod:byte;mi,mi1:string;
Begin
I:=Ellenoriz(OrgFv,Hkod);
if Hkod=0
   then begin
        mi:=FuggvenyAlakit(OrgFv); { FÅggvÇnyek operandus† alak°t†sa }
        mi:=LAtalakit(mi);         { Lengyel form†v† alak°t†s        }
        VErtekAd(mi);              { V†ltoz¢k behelyes°tÇse          }
        mi1:=FuggvenyKeplet;       { F(x,y,...) alak elkÇsz°tÇse     }
        if ValtozoNum=0
           then Eredmeny(mi1,mi,OrgFv)
           else VErtek_Main(mi1,mi,OrgFv);
        end
    else Hiba(HKod);
End;

Procedure Main;
var C:CommandType;mi1:string;
Begin
ClearCommandPuffer;
repeat
      CommandCode:=0;SetMouseFocus;Expression.SetKeyFocus;
      repeat
            If GetCommand(C)<>0 then TObjectProcess(C);
      until CommandCode<>0;
      Case CommandCode of
           _OkButtonCode   : begin
                             mi1:=Expression.EditText;
                             mi1:=Copy(mi1,1,(length(mi1)-1));
                             If mi1<>'' then KiErtekeles(mi1);
                             end;
           _CalcButtonCode : begin
                             end;
           end;
until CommandCode=_SystemExitButtonCode;
End;

{****************************************************************************}
{***                KÇpernyã/EgÇr inicializ†l†s/lez†r†s                   ***}
{****************************************************************************}

Function Init_Video:byte;
Begin
If SetGraphMode(VMode)<>0 then begin Init_Video:=1;Exit;end;
Init_Video:=0;
End;

Function Init_Mouse:byte;
Begin
If MouseInit(MouseAct,PixRat,MDVX,MDVY)=0
   then Init_Mouse:=1
   else begin Init_Mouse:=0;MouseShow;end;
End;

Procedure VideoDone;
Begin
Asm mov  ax,0003h;int 10h End;
WriteLn(ProgramName);
End;

{****************************************************************************}
{***                  Objektumok inicializ†l†sa/lez†r†sa                  ***}
{****************************************************************************}

Procedure ObjectInit;
Begin
Ok2Button.Init(2,VEditX+6,GetMaxY-65,_Ok2ButtonString);Ok2Button.Off;
UjKepletButton.Init(3,VEditX+6+195,GetMaxY-65,_UjKepletButtonString);UjKepletButton.Off;
CalcButton.Init(3,VEditX+6+300,GetMaxY-65,_CalcButtonString);CalcButton.Off;
OkButton.Init(1,GetMaxX-124,GetMaxY-24,_OkButtonString);
ExitButton.Init(0,GetMaxX-66,GetMaxY-24,_SystemExitButtonString);
EditY:=GetMaxY-24;Expression.Init(0,EditX,EditY,(GetMaxX-200) div 8,'');
ExpressionPuffer[1]:=0;EpMut:=1;
ExpressionsText.Init(1,VEditX+206,VEditY+1+6,(GetMaxX-VEditX-233) div 8,(VEditY+(GetMaxY-200)) div 11-1,@ExpressionPuffer);
TimeText.Init(1,GetMaxX-92,11,11,2,nil);
SetTimer(1,18,0,0,Seg(TimeText),Ofs(TimeText));
End;

Procedure ObjectDone;
Begin
SetTimer(1,0,0,0,0,0);
TimeText.Done;
ExpressionsText.Done;
Expression.Done;
ExitButton.Done;
OkButton.Done;
CalcButton.Done;
UjKepletButton.Done;
Ok2Button.Done;
End;

{****************************************************************************}
{***                             Inicializ†l†s                            ***}
{****************************************************************************}

Procedure Init_Picture;
Begin
MouseHide;
ClearScreen(BackGroundColor);
BorderDraw_3(VEditX,VEditY,10*9+101,GetMaxY-120,BackgroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_3(VEditX+10*9+110,VEditY+(GetMaxY-140),GetMaxX-215,20,BackgroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_3(1,5,GetMaxX-8,20,BackgroundColor,DBackGroundColor,LBackGroundColor);
BorderDraw_2a(VEditX+202,VEditY+1,GetMaxX-VEditX-233,VEditY+(GetMaxY-200),0,DBackGroundColor,LBackGroundColor);
SetTextBackColor(BackgroundColor);SetColor(PTextColor1);SetTextOver(0);
Rom_8x14;
SetColor(PTextColor2);OutStringXY(EditX-56,EditY+4,'KÇplet:');
SetColor(PTextColor1);OutStringXY(EditX-56-1,EditY+4-1,'KÇplet:');
SetColor(PTextColor2);OutStringXY(VEditX+4,VEditY+10,'       V†ltoz¢k');
SetColor(PTextColor1);OutStringXY(VEditX+4-1,VEditY+10-1,'       V†ltoz¢k');
SetColor(PTextColor2);OutStringXY(10,12,ProgramName);
SetColor(ProgramNameColor);OutStringXY(9,11,ProgramName);
MouseShow;
End;

Procedure Init_Data;
Begin
EditY:=GetMaxY-24;
End;

Procedure Init;
Begin
If Init_Video<>0
   then begin WriteLn('Nem sikerÅlt a videom¢d inicializ†l†sa!');Exit;end;
PictureOff;
Init_Mouse;
Init_Data;
Init_Picture;
ObjectInit;
PictureOn;
End;

{****************************************************************************}
{****************************************************************************}
{****************************************************************************}

BEGIN
Init;
TProcOn;
Main;
TProcOff;
ObjectDone;
VideoDone;
END.