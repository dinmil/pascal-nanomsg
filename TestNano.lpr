program TestNano;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, nano, Sockets, NanoMsgClass
  { you can add units after this };


function node0 (url: string): integer;
var sock: integer;
    myresult: integer;
    mybuffer: array[0..256-1] of char;
    myrecvcount: integer;
begin
  sock := nn_socket (AF_SP, NN_PULL);
  if sock < 0 then begin
     writeln('errorcode: ' , nn_errno);
     writeln('errortext: ' , nn_strerror(nn_errno));
  end
  else begin
    myresult := nn_bind (sock, pchar(url));
    while true do begin
      FillByte(mybuffer, SizeOf(mybuffer), 0);
      myrecvcount := nn_recv (sock, @mybuffer, sizeof(mybuffer), 0);
      writeln ('NODE0: RECEIVED ', string(mybuffer));
    end;
    nn_shutdown (sock, 0);
  end;
end;

function node1 (url: string; msg: string): integer;
var sz_msg: integer;
    sock: integer;
    myresult: integer;
    mysendcount: integer;
begin
  sz_msg := length(msg);
  sock := nn_socket (AF_SP, NN_PUSH);
  writeln('sock: ' , sock);
  if sock < 0 then begin
     writeln('errorcode: ' , nn_errno);
     writeln('errortext: ' , nn_strerror(nn_errno));
  end
  else begin
    myresult := nn_connect(sock, pchar(url));

    writeln ('NODE1: SENDING ', msg);
    mysendcount := nn_send (sock, @msg[1], sz_msg, 0);
    if mysendcount < 0 then begin
      writeln('errorcode: ' , nn_errno);
      writeln('errortext: ' , nn_strerror(nn_errno));
    end;
    nn_shutdown (sock, 0);
  end;
end;

function node0Class (url: string): integer;
var mybuffer: array[0..256-1] of char;
    myrecvcount: integer;
    nanosocket: TNanoMsgSocket;
begin
  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_PULL);
    writeln('sock: ' , nanosocket._Socket);
    nanosocket.BindSocket(url);
    while true do begin
      FillByte(mybuffer, SizeOf(mybuffer), 0);
      myrecvcount := nanosocket.Recv (@mybuffer, sizeof(mybuffer), 0);
      writeln ('NODE0CLASS: RECEIVED ', string(mybuffer));
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


function node1Class (url: string; msg: string): integer;
var sz_msg: integer;
    myresult: integer;
    mysendcount: integer;
    nanosocket: TNanoMsgSocket;
begin
  sz_msg := length(msg);

  nanosocket := nil;

  try
    nanosocket := TNanoMsgSocket.Create();
    nanosocket.GetSocket(NN_PUSH);
    writeln('sock: ' , nanosocket._Socket);
    nanosocket.ConnectSocket(url);

    writeln ('NODE1CLASS: SENDING ', msg);
    mysendcount := nanosocket.Send (@msg[1], sz_msg, 0);
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

begin
  if (ParamCount = 0) or (ParamStr(1) = 'node0') then begin
    if ParamCount = 0 then begin
      node0 ('tcp://*:5558');
    end
    else begin
      node0 (ParamStr(2));
    end;
    exit;
  end
  else if ParamStr(1) = 'node1' then begin
    node1 (ParamStr(2), ParamStr(3));
    exit;
  end
  else if ParamStr(1) = 'node0class' then begin
    node0Class (ParamStr(2));
    exit;
  end
  else if ParamStr(1) = 'node1class' then begin
    node1Class (ParamStr(2), ParamStr(3));
    exit;
  end
  else begin
      writeln (StdErr, 'Usage: TestNano (node0, node1, node0class, node1class) url message');
      writeln (StdErr, 'TestNano node0 tcp://*:5558');
      writeln (StdErr, 'TestNano node1 tcp://127.0.0.1:5558 test_message');
      writeln (StdErr, 'TestNano node0class tcp://*:5558');
      writeln (StdErr, 'TestNano node1class tcp://127.0.0.1:5558 test_message');
      exit
  end;
end.

