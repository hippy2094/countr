(* Recursively count files in a directory *)
program countr;
{$mode objfpc}{$H+}
uses Classes, SysUtils;

var
  fcount: LongInt;
  
procedure DoCount(mask: String; inDir: String);
var
  s: TSearchRec;  
begin
  writeln('Searching for ',mask,' in ',inDir);
  if FindFirst(IncludeTrailingPathDelimiter(inDir) + '*',faAnyFile, s) = 0 then
  begin
    repeat
      if (s.Attr and faDirectory) <> faDirectory then
      begin
        if (Lowercase(ExtractFileExt(s.Name)) = Lowercase(ExtractFileExt(mask))) or (mask = '*.*') then
        begin
          inc(fcount);  
        end;    
      end;
      if (s.Name <> '.') and (s.Name <> '..') and ((s.Attr and faDirectory) = faDirectory) then
      begin
        DoCount(mask, IncludeTrailingPathDelimiter(inDir) + s.Name);
      end;
    until FindNext(s) <> 0;
  end;
end;

begin
  fcount := 0;
  
  // ParamStr(1) = path
  // ParamStr(2) = mask
 
  DoCount(ParamStr(2),ParamStr(1));
  writeln(fcount, ' file(s) found.');
end.