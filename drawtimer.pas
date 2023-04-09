uses crt,sysutils,windows;
var kc:       char;
    spf:      boolean;
    ts:       TTimeStamp;
    millis:   double;
    mytimer:  integer;
    mymax:    integer;
    mypause:  boolean;
    myexpir:  byte;
    min_c:    byte;
    sec_c:    byte;

procedure show_pause;
begin
  gotoxy(2,2);  textcolor(14);   if mypause then write('||') else write('>>');
end;

procedure show_timer;
begin
  gotoxy(8,1);   textcolor(15);   write('  ');
  gotoxy(8,1);                    write(mytimer);
end;

procedure show_expired;
begin
  myexpir:=0;
  repeat
    ts:=DateTimeToTimeStamp(Now);
    if(((ts.date+ts.time)-millis)>=240) then begin
      myexpir:=myexpir+1;
      gotoxy(5,2);
      if((myexpir mod 2)=0) then textattr:=$e4 else textattr:=$4e;
      write('          TIMER END           ');
      millis:=ts.date+ts.time;
    end;
  until keypressed or (myexpir>41);
  if keypressed then readkey;                 // eatkey to prevent pause on spc
  textcolor(3);
  textbackground(0);
  gotoxy(5,2);
  write('                              ');
end;

procedure reset_timeline_sec;
begin
  sec_c:=0;
  gotoxy(5,2);   textcolor(3);    write('                              ');
end;

procedure reset_timeline_min;
begin
  min_c:=0;
  gotoxy(5,3);   textcolor(3);    write('                                        ');
end;

procedure adv_timeline;
begin
  sec_c:=sec_c+1;
  if(sec_c>59) then begin
    min_c:=min_c+1;
    reset_timeline_sec;
  end else begin
    gotoxy(5+(sec_c div 2),2);   textcolor(3);    write('.');
  end;
  if(min_c>=mytimer) then begin
    sec_c:=0;
    show_expired;
    reset_timeline_min;
  end else begin
    gotoxy(5+min_c,3);   textcolor(3);    write('|');
  end;
end;

procedure inc_timeline;
begin
  min_c:=min_c+1;
  gotoxy(5+min_c,3);   textcolor(3);    write('|');
end;

procedure dec_timeline;
begin
  min_c:=min_c-1;
  gotoxy(5+min_c+1,3);   textcolor(3);    write('  ');
end;

procedure SetConsoleWindowSize;
var
  Rect: TSmallRect;
  Coord: TCoord;
begin
  Rect.Left := 1;
  Rect.Top := 1;
  Rect.Right := 70;  // notice horiz scroll bar once the following executes
  Rect.Bottom := 5;
  Coord.X := Rect.Right + 1 - Rect.Left;
  Coord.y := Rect.Bottom + 1 - Rect.Top;
  SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
  SetConsoleWindowInfo(GetStdHandle(STD_OUTPUT_HANDLE), True, Rect);
end;

begin
  clrscr;
  cursoroff;
  gotoxy(1,5);
  setconsoletitle('DrawTimer 0.1 - 090422      tlg@arleentg');
  sleep(500);
  SetConsoleWindowSize;

  textcolor(10);   write('Cursor keys ');
  textcolor(11);   write('modify, ');
  textcolor(10);   write('Spc ');
  textcolor(11);   write('pause, ');
  textcolor(10);   write('Bksp ');
  textcolor(11);   write('reset, ');
  textcolor(10);   write('Alt+X ');
  textcolor(11);   write('exit.');

  ts:=DateTimeToTimeStamp(Now);
  millis:=ts.date+ts.time;
  spf:=false;
  mytimer:=4;
  mymax:=40;
  min_c:=0;
  sec_c:=0;
  mypause:=false;

  gotoxy(1,1);   textcolor(14);   write('Timer: ');
  show_pause;
  show_timer;

  repeat
    ts:=DateTimeToTimeStamp(Now);
    if(((ts.date+ts.time)-millis)>=1000) then begin
      if not mypause then adv_timeline;
      millis:=ts.date+ts.time;
    end;
    if keypressed then begin
      kc:=readkey;
      spf:=false;
      if(ord(kc)=0) then begin
        spf:=true;
        kc:=readkey;
      end;
//      writeln(spf,' ',ord(kc));                            // debug, show keycode
      if(    spf and (ord(kc)=72)) then begin                                       // up
        mytimer:=mytimer+1; if(mytimer>mymax) then mytimer:=mymax; show_timer; reset_timeline_sec; reset_timeline_min;
      end;
      if(    spf and (ord(kc)=80)) then begin                                       // dn
        mytimer:=mytimer-1; if(mytimer<1)     then mytimer:=1;     show_timer; reset_timeline_sec; reset_timeline_min;
      end;
      if(    spf and (ord(kc)=75) and (min_c>0))            then dec_timeline;      // L
      if(    spf and (ord(kc)=77) and (min_c<=(mytimer-2))) then inc_timeline;      // R
      if(not spf and (ord(kc)=8))  then begin  reset_timeline_sec; reset_timeline_min;  end;      // reset
      if(not spf and (ord(kc)=32)) then begin  mypause:=not mypause; show_pause;        end;      // pause
    end;
  until (spf and (ord(kc)=45));
end.
