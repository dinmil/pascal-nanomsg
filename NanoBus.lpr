program NanoBus;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, nano, Sockets, NanoMsgClass
  { you can add units after this };


function server (nodename, url: string): integer;
var nanosocket: TNanoMsgSocket;
    MyString: String;
    MyDeadLine: Integer;
    F: Integer;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_BUS);
    writeln('sock: ' , nanosocket._Socket);

    writeln('BindSocket: ', url);
    nanosocket.BindSocket(url);
    writeln('Socket Binded: ', url);
    Sleep(1);

    // connect to all other nodes
    if ParamCount >= 3 then begin
      for F := 3 to ParamCount do begin
        nanosocket.ConnectSocket(ParamStr(F));
      end;
    end;
    Sleep(1);

    MyDeadLine := 50000;
    writeln('SetSockOptInteger: NN_RCVTIMEO');
    nanosocket.SetSockOptInteger(NN_RCVTIMEO, MyDeadLine, NN_SOL_SOCKET);
    writeln('GetSockOptInteger: ' , nanosocket.GetSockOptInteger(NN_RCVTIMEO, NN_SOL_SOCKET));

    writeln('Sending on the bus: ', nodename);
    nanosocket.Send(nodename);

    while true do begin
      MyString := '';
      nanosocket.Recv(MyString);
      if MyString <> '' then begin
        writeln(nodename, ' RECEIVED FROM BUS: ', MyString);
      end;
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
var MyName: String = 'Name';

begin
  MyAppName := ExtractFileName(ParamStr(0));
  if (ParamCount >= 3) then begin
    if ParamCount > 1 then begin
      MyUrl := ParamStr(2);
    end;
    server(ParamStr(1), MyUrl);
    exit;
  end;
  writeln (StdErr, 'Usage: ' , MyAppName, ' (nodename) (urlmy) (url2) (url3)...');
  writeln (StdErr, 'Examples');
  writeln (StdErr, MyAppName, ' node0 tcp://127.0.0.1:5558 tcp://127.0.0.1:5559 tcp://127.0.0.1:5560 tcp://127.0.0.1:5561');
  writeln (StdErr, MyAppName, ' node1 tcp://127.0.0.1:5559 tcp://127.0.0.1:5558 tcp://127.0.0.1:5560 tcp://127.0.0.1:5561');
  writeln (StdErr, MyAppName, ' node2 tcp://127.0.0.1:5560 tcp://127.0.0.1:5558 tcp://127.0.0.1:5559 tcp://127.0.0.1:5561');
  writeln (StdErr, MyAppName, ' node3 tcp://127.0.0.1:5561 tcp://127.0.0.1:5558 tcp://127.0.0.1:5559 tcp://127.0.0.1:5560');
  exit
end.

