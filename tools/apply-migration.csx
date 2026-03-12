#!/usr/bin/env dotnet-script
#r "nuget: Microsoft.Data.Sqlite, 8.0.0"

using Microsoft.Data.Sqlite;

var dbPath = args[0];
var sqlFile = args[1];

using var conn = new SqliteConnection($"Data Source={dbPath}");
conn.Open();

var sql = File.ReadAllText(sqlFile);
var statements = sql.Split(';').Select(s => s.Trim()).Where(s => s.Length > 0 && !s.StartsWith("--"));

foreach (var stmt in statements)
{
    try {
        using var cmd = conn.CreateCommand();
        cmd.CommandText = stmt;
        cmd.ExecuteNonQuery();
        Console.WriteLine($"OK: {stmt[..Math.Min(60, stmt.Length)]}...");
    } catch (Exception ex) {
        Console.WriteLine($"Skip: {ex.Message}");
    }
}
Console.WriteLine("Done.");
