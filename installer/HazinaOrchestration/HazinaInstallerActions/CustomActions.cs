using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Nodes;
using WixToolset.Dtf.WindowsInstaller;

namespace HazinaInstallerActions
{
    public class CustomActions
    {
        [CustomAction]
        public static ActionResult UpdateAppSettings(Session session)
        {
            session.Log("Begin UpdateAppSettings");

            try
            {
                // Get properties from installer
                string installPath = session.CustomActionData["INSTALLFOLDER"];
                string terminalExecutable = session.CustomActionData["TERMINAL_EXECUTABLE"];
                string terminalWorkingDir = session.CustomActionData["TERMINAL_WORKING_DIR"];

                session.Log($"Install Path: {installPath}");
                session.Log($"Terminal Executable: {terminalExecutable}");
                session.Log($"Terminal Working Dir: {terminalWorkingDir}");

                // Path to appsettings.json
                string appSettingsPath = Path.Combine(installPath, "appsettings.json");

                if (!File.Exists(appSettingsPath))
                {
                    session.Log($"ERROR: appsettings.json not found at {appSettingsPath}");
                    return ActionResult.Failure;
                }

                // Read existing appsettings.json
                string jsonContent = File.ReadAllText(appSettingsPath);
                var jsonObject = JsonNode.Parse(jsonContent);

                if (jsonObject == null)
                {
                    session.Log("ERROR: Failed to parse appsettings.json");
                    return ActionResult.Failure;
                }

                // Update terminal configuration
                var orchestration = jsonObject["AgenticOrchestration"];
                if (orchestration == null)
                {
                    session.Log("ERROR: AgenticOrchestration section not found");
                    return ActionResult.Failure;
                }

                var terminal = orchestration["Terminal"];
                if (terminal == null)
                {
                    session.Log("ERROR: Terminal section not found");
                    return ActionResult.Failure;
                }

                // Update values with escaped backslashes for JSON
                terminal["DefaultCommand"] = terminalExecutable.Replace("\\", "\\\\");
                terminal["DefaultWorkingDirectory"] = terminalWorkingDir.Replace("\\", "\\\\");

                // Update database and logs paths to use installation directory
                string dataPath = Path.Combine(installPath, "data");
                string logsPath = Path.Combine(installPath, "logs");

                orchestration["DatabasePath"] = Path.Combine(dataPath, "agent-activity.db").Replace("\\", "\\\\");
                orchestration["LogsPath"] = logsPath.Replace("\\", "\\\\");

                var sessionLogging = orchestration["SessionLogging"];
                if (sessionLogging != null)
                {
                    sessionLogging["BasePath"] = Path.Combine(logsPath, "agent-sessions").Replace("\\", "\\\\");
                }

                // Create directories if they don't exist
                Directory.CreateDirectory(dataPath);
                Directory.CreateDirectory(logsPath);
                Directory.CreateDirectory(Path.Combine(logsPath, "agent-sessions"));

                // Write updated configuration
                var options = new JsonSerializerOptions
                {
                    WriteIndented = true
                };

                string updatedJson = jsonObject.ToJsonString(options);
                File.WriteAllText(appSettingsPath, updatedJson);

                session.Log($"Successfully updated appsettings.json");
                session.Log($"Terminal command: {terminalExecutable}");
                session.Log($"Working directory: {terminalWorkingDir}");

                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in UpdateAppSettings: {ex.Message}");
                session.Log($"Stack trace: {ex.StackTrace}");
                return ActionResult.Failure;
            }
        }
    }
}
