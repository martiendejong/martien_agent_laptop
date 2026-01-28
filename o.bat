@echo off
:: Quick launcher for Hazina Agentic Orchestration
:: HTTPS on port 5123, accessible via Tailscale

title Hazina Orchestration
echo.
echo  ╔═══════════════════════════════════════════════════════════╗
echo  ║         HAZINA AGENTIC ORCHESTRATION                      ║
echo  ╠═══════════════════════════════════════════════════════════╣
echo  ║  Local:     https://localhost:5123                        ║
echo  ║  Tailscale: https://desktop-ecbaunu.tailca9ff1.ts.net:5123║
echo  ║  Swagger:   https://localhost:5123/swagger                ║
echo  ║  Login:     bosi / Th1s1sSp4rt4!                          ║
echo  ╚═══════════════════════════════════════════════════════════╝
echo.

cd /d "C:\stores\orchestration"
start "" "https://localhost:5123"
HazinaOrchestration.exe
