program Test;

uses
  Windows,
  SysUtils,
  Flash in 'Flash.pas',
  Disk in 'Disk.pas';

begin
  Disk_Kill;                                   
  Flash_Kill;
end.
