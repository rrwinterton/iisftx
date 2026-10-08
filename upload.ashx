<%@ WebHandler Language="C#" Class="UploadHandler" %>
using System;
using System.IO;
using System.Web;

public class UploadHandler : IHttpHandler {
    public void ProcessRequest(HttpContext context) {
        context.Response.ContentType = "text/plain";
        
        try {
            // Check if a file was sent in the request
            if (context.Request.Files.Count > 0) {
                HttpPostedFile file = context.Request.Files[0];
                
                if (file == null || string.IsNullOrEmpty(file.FileName)) {
                    context.Response.StatusCode = 400;
                    context.Response.Write("Error: No valid file attached.");
                    return;
                }
                
                // Map the path to the "downloads" subdirectory on the IIS server
                string targetDir = context.Server.MapPath("downloads/");
                
                // Create the directory if it does not exist
                if (!Directory.Exists(targetDir)) {
                    Directory.CreateDirectory(targetDir);
                }
                
                // Sanitize file name to prevent path traversal attacks
                string safeFileName = Path.GetFileName(file.FileName);
                string destinationPath = Path.Combine(targetDir, safeFileName);
                
                // Save the uploaded file
                file.SaveAs(destinationPath);
                
                context.Response.StatusCode = 200;
                context.Response.Write("Success: File \"" + safeFileName + "\" saved successfully (" + FormatSize(file.ContentLength) + ").");
            } else {
                context.Response.StatusCode = 400;
                context.Response.Write("Error: No file received in the request.");
            }
        } catch (UnauthorizedAccessException ex) {
            context.Response.StatusCode = 500;
            context.Response.Write("Error: Permission denied writing to downloads folder. " + ex.Message);
        } catch (Exception ex) {
            context.Response.StatusCode = 500;
            context.Response.Write("Error: " + ex.Message);
        }
    }

    private static string FormatSize(long bytes) {
        if (bytes <= 0) return "0 B";
        string[] suffixes = { "B", "KB", "MB", "GB", "TB" };
        int idx = 0;
        double dBytes = bytes;
        while (dBytes >= 1024 && idx < suffixes.Length - 1) {
            dBytes /= 1024;
            idx++;
        }
        return string.Format("{0:0.##} {1}", dBytes, suffixes[idx]);
    }

    public bool IsReusable {
        get { return false; }
    }
}
