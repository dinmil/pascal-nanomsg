program NanoPubSub;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, nano, Sockets, NanoMsgClass
  { you can add units after this };


function server (url: string): integer;
var nanosocket: TNanoMsgSocket;
    MyString: String;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_PUB);
    writeln('sock: ' , nanosocket._Socket);
    nanosocket.BindSocket(url);
    while true do begin
      MyString := 'server publishing date ' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now);
      nanosocket.Send(MyString);
      writeln(MyString);
      sleep(1000);
    end;
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

function client (url: string): integer;
var nanosocket: TNanoMsgSocket;
    MyString: String;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_SUB);
    writeln('sock: ' , nanosocket._Socket);
    writeln('setting subscribe filter: server');
//    nanosocket.SetSockOptString(NN_SUB_SUBSCRIBE, '', NN_SUB);
    nanosocket.SetSockOptString(NN_SUB_SUBSCRIBE, 'server', NN_SUB);
    nanosocket.GetSockOptString(NN_SUB_SUBSCRIBE, NN_SUB); // this return an error for subscribe ENOPROTOOPT
    writeln('subscribe filter set ');
    nanosocket.ConnectSocket(url);
    while true do begin
      nanosocket.Recv(MyString);
      writeln('receive message: ', MyString);
    end;
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
    if (ParamStr(1) = 'server') then begin
      server(MyUrl);
      exit
    end
    else if ParamStr(1) = 'client' then begin
      client(MyUrl);
      exit
    end
  end;
  writeln (StdErr, 'Usage: ' , MyAppName, ' client (server) (url)');
  writeln (StdErr, 'Examples');
  writeln (StdErr, MyAppName, ' server tcp://127.0.0.1:5558');
  writeln (StdErr, MyAppName, ' client tcp://127.0.0.1:5558');
  writeln (StdErr, MyAppName, ' server');
  writeln (StdErr, MyAppName, ' client');
  exit
end.

