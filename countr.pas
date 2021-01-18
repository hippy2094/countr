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

procedure main(path: String; fmask: String);
var
  mask, inDir: String;
  fcount: Integer;
  Result: Integer;
begin
  fcount := 0;
  Result := 0;
  
  // Directory doesn't exist?
  if not DirectoryExists(path) then Result := -1
  else inDir := path;
  // No mask specified?
  if Length(fmask) > 0 then mask := fmask
  else mask := '*.*'; 
  // Bash appears to expand filemasks into actual parameters
  if not AnsiStartsStr('*',fmask) then
  begin
    mask := '*' + ExtractFileExt(fmask);
  end;
  // No parameters?
  if (Length(path) < 1) and (Length(fmask) < 1) then Result := -2;

  if Result = 0 then DoCount(mask,inDir,fcount);

  case Result of
    -2: writeln('USAGE: countr <path> [searchmask]');
    -1: writeln('ERROR: Directory not found.');
  else
    writeln(fcount, ' files found.');
  end;
end;

begin
  // ParamStr(1) = path
  // ParamStr(2) = mask  
  main(ParamStr(1),ParamStr(2));
end.
