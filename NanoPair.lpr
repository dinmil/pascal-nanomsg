program NanoPair;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, nano, Sockets, NanoMsgClass
  { you can add units after this };

var MySendCount, MyRecvCount: Integer;

function send_name (InSocket: TNanoMsgSocket; var OutName: string): integer;
begin
  Writeln('Sending: ', MySendCount, ' ', OutName);
  Result := InSocket.Send(OutName);
end;

function recv_name (InSocket: TNanoMsgSocket; var OutName: string): integer;
var MyName: String;
begin
  Result := InSocket.Recv(MyName, NN_DONTWAIT, 2);
  if MyName <> '' then begin
    Inc(MyRecvCount);
    Writeln('Received: ', MyRecvCount, ' ', MyName);
  end;
end;

function send_recv(InSocket: TNanoMsgSocket; var OutName: string): integer;
var MyTo: Integer = 100;
    MyName: String;
begin
  while true do begin
    recv_name(InSocket, MyName);
    sleep(1);
    send_name(InSocket, OutName);
  end;
end;

function node0 (url: string): integer;
var mybuffer: array[0..256-1] of char;
    myrecvcount: integer;
    nanosocket: TNanoMsgSocket;
    MyString: String;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_PAIR);
    writeln('sock: ' , nanosocket._Socket);
    nanosocket.BindSocket(url);
    MyString := 'NODE0';
    send_recv(nanosocket, MyString);
    FreeAndNil(nanosocket)
  except
    on E1: ENanoMsgError do begin
      writeln('errorcode: ' , E1._ErrNo);
      writeln('errortext: ' , E1._ErrMsg);
      if nanosocket <> nil then FreeAndNil(nanosocket);
    end;
    on E2: Exception do begin
      writeln('error: ' , E2.Message);
      if nanosocket <> nil then FreeAndNil(nanosocket);
    end;
  end;
end;

function node1 (url: string): integer;
var mybuffer: array[0..256-1] of char;
    myrecvcount: integer;
    nanosocket: TNanoMsgSocket;
    MyString: String;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_PAIR);
    writeln('sock: ' , nanosocket._Socket);
    nanosocket.ConnectSocket(url);
    MyString := 'NODE1';
    send_recv(nanosocket, MyString);
    FreeAndNil(nanosocket)
  except
    on E1: ENanoMsgError do begin
      writeln('errorcode: ' , E1._ErrNo);
      writeln('errortext: ' , E1._ErrMsg);
      if nanosocket <> nil then FreeAndNil(nanosocket);
    end;
    on E2: Exception do begin
      writeln('error: ' , E2.Message);
      if nanosocket <> nil then FreeAndNil(nanosocket);
    end;
  end;
end;

var MyUrl: string = 'tcp://127.0.0.1:5558';
var MyAppName: String;

begin
  MyAppName := ExtractFileName(ParamStr(0));
  if (ParamCount > 0) then begin
    if ParamCount > 1 then begin
      MyUrl := ParamStr(2);
    end;
    if (ParamStr(1) = 'node0') then begin
      node0(MyUrl);
      exit
    end
    else if ParamStr(1) = 'node1' then begin
      node1(MyUrl);
      exit
    end
  end;
  writeln (StdErr, 'Usage: ' , MyAppName, ' node0 (node1) (url)');
  writeln (StdErr, 'Examples');
  writeln (StdErr, MyAppName, ' node0 tcp://127.0.0.1:5558');
  writeln (StdErr, MyAppName, ' node1 tcp://127.0.0.1:5558');
  writeln (StdErr, MyAppName, ' node0');
  writeln (StdErr, MyAppName, ' node1');
  exit
end.

