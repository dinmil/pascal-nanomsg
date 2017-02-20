program NanoSurvey;

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
    MyDeadLine: Integer;
    F: Integer;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_SURVEYOR);
    writeln('sock: ' , nanosocket._Socket);

    MyDeadLine := 5000;
    nanosocket.SetSockOptInteger(NN_SURVEYOR_DEADLINE, MyDeadLine, NN_SURVEYOR);
    writeln('GetSockOptInteger: ' , nanosocket.GetSockOptInteger(NN_SURVEYOR_DEADLINE, NN_SURVEYOR));
    nanosocket.BindSocket(url);
    Sleep(1000);

    for F := 0 to 4 do begin
      try
        MyString := 'SERVER: SENDING DATE SURVEY REQUEST ' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + #0;
        writeln(MyString);
        nanosocket.Send(MyString);

        while true do begin
          MyString := '';
          nanosocket.Recv(MyString);
          if MyString <> '' then begin
            writeln('SERVER: RECEIVED ', MyString, ' SURVEY RESPONSE');
          end;
        end;
      except
        on E: Exception do begin
          writeln(E.Message);
        end;
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

function client (url: string; clientname: string): integer;
var nanosocket: TNanoMsgSocket;
    MyString: String;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_RESPONDENT);
    writeln('sock: ' , nanosocket._Socket);
    nanosocket.ConnectSocket(url);
    while true do begin
      nanosocket.Recv(MyString);
      if MyString <> '' then begin
        writeln('CLIENT (' + clientname + '): RECEIVED "' + MyString + '" SURVEY REQUEST');
        writeln('CLIENT (' + clientname + '): SENDING DATE SURVEY RESPONSE "' + clientname + '"');
        MyString := IntToStr(LEngth(MyString));
        nanosocket.Send(MyString);
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
  if (ParamCount > 0) then begin
    if ParamCount > 1 then begin
      MyUrl := ParamStr(2);
    end;
    if (ParamStr(1) = 'server') then begin
      server(MyUrl);
      exit
    end
    else if ParamStr(1) = 'client' then begin
      if ParamCount > 2 then MyName := ParamStr(3);
      client(MyUrl, MyName);
      exit
    end
  end;
  writeln (StdErr, 'Usage: ' , MyAppName, ' (client/server) (url) (name)');
  writeln (StdErr, 'Examples');
  writeln (StdErr, MyAppName, ' server tcp://127.0.0.1:5558');
  writeln (StdErr, MyAppName, ' client tcp://127.0.0.1:5558');
  writeln (StdErr, MyAppName, ' server');
  writeln (StdErr, MyAppName, ' client');
  exit
end.

