(* Recursively count files in a directory *)
program countr;
{$mode objfpc}{$H+}
uses Classes, SysUtils, StrUtils;

procedure DoCount(mask: String; inDir: String; var filecount: Integer);
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
          inc(filecount);  
        end;    
      end;
      if (s.Name <> '.') and (s.Name <> '..') and ((s.Attr and faDirectory) = faDirectory) then
      begin
        DoCount(mask, IncludeTrailingPathDelimiter(inDir) + s.Name, filecount);
      end;
    until FindNext(s) <> 0;
  end;
  FindClose(s);
end;

procedure main;
var
  mask, inDir: String;
  fcount: Integer;
  Result: Integer;
begin
  fcount := 0;
  Result := 0;
  
  // ParamStr(1) = path
  // ParamStr(2) = mask

  // Directory doesn't exist?
  if not DirectoryExists(ParamStr(1)) then Result := -1
  else inDir := ParamStr(1);
  // No mask specified?
  if ParamCount = 1 then mask := '*.*'
  else mask := ParamStr(2);
  // Bash appears to expand filemasks into actual parameters
  if not AnsiStartsStr('*',ParamStr(2)) then
  begin
    mask := '*' + ExtractFileExt(ParamStr(2));
  end;
  // No parameters?
  if ParamCount = 0 then Result := -2;

  if Result < 1 then DoCount(mask,inDir,fcount);
  
  case Result of    
    -2: writeln('USAGE: countr <path> [searchmask]');  
    -1: writeln('ERROR: Directory not found.');
  else
    writeln(fcount, ' files found.');
  end;  
end;

begin
  main;
end.
