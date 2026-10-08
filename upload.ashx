<%@ WebHandler Language="C#" Class="UploadHandler" %>
using System;
using System.IO;
using System.Web;

public class UploadHandler : IHttpHandler {
    public void ProcessRequest(HttpContext context) {
        // Check if a file was sent in the request
        if (context.Request.Files.Count > 0) {
            HttpPostedFile file = context.Request.Files[0];
            
            // Map the path to the "downloads" subdirectory on the IIS server
            string targetDir = context.Server.MapPath("downloads/");
            
            // Create the directory if it does not exist
            if (!Directory.Exists(targetDir)) {
                Directory.CreateDirectory(targetDir);
            }
            
            // Construct the final file path and save it
            string path = Path.Combine(targetDir, Path.GetFileName(file.FileName));
            file.SaveAs(path);
            
            context.Response.ContentType = "text/plain";
            context.Response.Write("Success: File placed in the server's downloads directory.");
        } else {
            context.Response.ContentType = "text/plain";
            context.Response.Write("Error: No file received.");
        }
    }

    public bool IsReusable {
        get { return false; }
    }
}
