# pascal-nanomsg
This is pascal translation of NanoMsg C header files. It contains precompiled dll's for WIN32 and WIN64 and detail instructions how to compile it.

To test the program.
Start one receiver with commands
TestNano node0 tcp://*:5558
or
TestNano node0class tcp://*:5558

Start one sender with commands
TestNano node1 tcp://127.0.0.1:5558 test_message
or
TestNano node1class tcp://127.0.0.1:5558 test_message

Difference between nano0 and nano0class is that nano0class use object pascal style programming and nano0 use C procedural style to achieve same functionality. Same logic apply for nano1 and nano1class.

This project is far from finished, but it shows how to send messages between applications with nanomsg library. It is not tested on any other enviroment other then WIN32 and WIN64. 

Any improvement is welcome. Any test is welcome.

Note. NanoMsg is like ZeroMQ, but it is written in plain C language, comparing to ZeroMQ which is written by the same author in C++ language. My test shows that ZeroMQ sends small messages (up to 5 KB) faster, and NanoMsg sends much faster longer messages. Both libraries are great and it is possible to make some pascal wrapper class which can handle both libraries.

Environment used to make this source is CodeTyphon 5.90 from PilotLogic. It should be possible to copile this application in Lazarus, FPC or Delphi.
