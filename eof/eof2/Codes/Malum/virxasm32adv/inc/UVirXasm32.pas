
//
// Unit file of VirXasm32 for Borland Delphi
// (X) Malum
//

unit UVirXasm32;

interface
function VirXasm32(pCode: Pointer): DWORD; cdecl;

implementation
function VirXasm32; external 'virxasm32.dll' name '_VirXasm32';

end.
