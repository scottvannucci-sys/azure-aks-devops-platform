var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => Results.Ok(new { service = "platform-api", status = "ok" }));
app.MapGet("/health", () => Results.Ok("healthy"));
app.MapGet("/version", () => Results.Ok(new { version = "1.0.0", build = Environment.GetEnvironmentVariable("BUILD_VERSION") ?? "local" }));

app.Run();

string ReadSecret(string path)
{
    try { return File.Exists(path) ? File.ReadAllText(path).Trim() : "missing"; }
    catch { return "error"; }
}

app.MapGet("/greeting", () =>
{
    var secret = ReadSecret("/mnt/secrets/PlatformApi--Greeting");
    return Results.Ok(new { greeting = secret });
});