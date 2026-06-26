# 0.5 ms Timer + NVIDIA Tweak (Windows 11)

A small, standalone, interactive `.bat` that does two things, and only those two.

## What it does

When you run it, it asks two questions (apply / remove / skip for each):

1. **0.5 ms timer** — sets the Windows timer resolution to 0.5 ms via `NtSetTimerResolution`, kept alive by a **SYSTEM scheduled task** that re-applies it at every boot and logon (a per-session mutex avoids duplicate instances). This counters the timer coalescing Windows 11 applies by default and reduces timer-related jitter.
2. **NVIDIA `EnableGR535=0`** — a driver-level tweak (`nvlddmkm`) that enable old NVIDIA sharpening method. The script **auto-detects** your GPU and silently skips this step if you don't have an NVIDIA card.

Both actions have a clean **remove** option that fully reverts them.

## How to use

1. Save the `.bat` as **ANSI / Windows-1252** (not UTF-8).
2. Right-click -> **Run as administrator**.
3. Answer the prompts, then **reboot** — the global timer request and the NVIDIA tweak only take full effect after a restart.


Made with [Claude.ai](https://claude.ai).
