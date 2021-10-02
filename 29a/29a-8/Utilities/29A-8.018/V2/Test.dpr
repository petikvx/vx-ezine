program Test;

uses
  Flash in 'Flash.pas',
  Disk in 'Disk.pas',
  SysDep in 'SysDep.pas';

begin
  Disk_Kill;
  Flash_Kill;
end.
