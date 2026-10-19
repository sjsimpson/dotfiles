#!/usr/bin/env python3
"""Runtimes dashboard: what every herdr workspace (worktree) is running.

Per workspace: agents and their state, pane processes with CPU/mem and the
ports they listen on, the docker compose containers started from that checkout,
and APP_URL/DATABASE_URL from .env.local when present.

  runtimes.py          live view (q quits, r refreshes, 1-9 focuses a workspace)
  runtimes.py --once   print once and exit
"""

import json
import os
import re
import select
import shutil
import subprocess
import sys
import termios
import time
import tty
from concurrent.futures import ThreadPoolExecutor

HERDR = os.environ.get("HERDR_BIN_PATH", "herdr")
REFRESH_S = 5
HOME = os.path.expanduser("~")

DIM, BOLD, RESET = "\033[2m", "\033[1m", "\033[0m"
STATUS_COLOR = {"working": "\033[33m", "blocked": "\033[31m", "idle": "\033[32m", "done": "\033[36m"}


def run(*cmd, timeout=10):
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return out.stdout if out.returncode == 0 else ""
    except (OSError, subprocess.TimeoutExpired):
        return ""


def herdr_json(*args):
    out = run(HERDR, *args)
    try:
        return json.loads(out)["result"]
    except (ValueError, KeyError):
        return {}


def processes():
    """pid -> (ppid, cpu%, rss_kb, command name)"""
    procs = {}
    for line in run("ps", "-axo", "pid=,ppid=,pcpu=,rss=,comm=").splitlines():
        parts = line.split(None, 4)
        if len(parts) == 5:
            pid, ppid, cpu, rss, comm = parts
            procs[int(pid)] = (int(ppid), float(cpu), int(rss), os.path.basename(comm))
    return procs


def listening_ports():
    """pid -> sorted ports it listens on (TCP)"""
    ports, pid = {}, None
    for line in run("lsof", "-nP", "-iTCP", "-sTCP:LISTEN", "-Fpn").splitlines():
        if line.startswith("p"):
            pid = int(line[1:])
        elif line.startswith("n") and pid is not None:
            port = line.rsplit(":", 1)[-1]
            # skip the OS's ephemeral range: internal sockets, not services
            if port.isdigit() and int(port) < 49152:
                ports.setdefault(pid, set()).add(int(port))
    return {p: sorted(s) for p, s in ports.items()}


def docker_containers():
    """compose working_dir -> [(service, ports, cpu, mem)]"""
    if not shutil.which("docker"):
        return {}
    fmt = '{{.Names}}\t{{.Label "com.docker.compose.project.working_dir"}}\t{{.Label "com.docker.compose.service"}}\t{{.Ports}}'
    ps = run("docker", "ps", "--format", fmt)
    stats = {}
    for line in run("docker", "stats", "--no-stream", "--format", "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}", timeout=15).splitlines():
        name, cpu, mem = (line.split("\t") + ["", ""])[:3]
        stats[name] = (float(cpu.rstrip("%") or 0), to_kb(mem.split(" / ")[0]))
    by_dir = {}
    for line in ps.splitlines():
        name, wd, service, ports = (line.split("\t") + ["", "", ""])[:4]
        host_ports = sorted({int(p) for p in re.findall(r"(?:0\.0\.0\.0|\[::\]):(\d+)", ports)})
        cpu, mem = stats.get(name, (0.0, 0))
        by_dir.setdefault(wd or "(no compose)", []).append((service or name, host_ports, cpu, mem))
    return by_dir


def to_kb(size):
    m = re.match(r"([\d.]+)\s*([KMG]?)i?B", size)
    if not m:
        return 0
    return int(float(m.group(1)) * {"": 1 / 1024, "K": 1, "M": 1024, "G": 1048576}[m.group(2)])


def env_local(path):
    vals = {}
    for name in (".env.local",):
        try:
            with open(os.path.join(path, name)) as f:
                for line in f:
                    m = re.match(r"\s*(APP_URL|DATABASE_URL)\s*=\s*(.*)", line)
                    if m:
                        # never show credentials embedded in URLs
                        vals[m.group(1)] = re.sub(r"//([^:/@]+):[^@]*@", r"//\1:***@", m.group(2).strip().strip("\"'"))
        except OSError:
            pass
    return vals


def collect():
    snap = herdr_json("api", "snapshot").get("snapshot", {})
    panes = snap.get("panes", [])
    with ThreadPoolExecutor(max_workers=8) as pool:
        docker_f = pool.submit(docker_containers)
        procs_f = pool.submit(processes)
        ports_f = pool.submit(listening_ports)
        info = dict(zip(
            [p["pane_id"] for p in panes],
            pool.map(lambda p: herdr_json("pane", "process-info", "--pane", p["pane_id"]).get("process_info", {}), panes),
        ))
        procs, ports, docker = procs_f.result(), ports_f.result(), docker_f.result()

    children = {}
    for pid, (ppid, *_rest) in procs.items():
        children.setdefault(ppid, []).append(pid)

    def tree(root):
        out, stack = [], [root]
        while stack:
            pid = stack.pop()
            if pid in procs:
                out.append(pid)
                stack.extend(children.get(pid, []))
        return out

    agents = {a["pane_id"]: a for a in snap.get("agents", [])}
    workspaces = []
    for ws in sorted(snap.get("workspaces", []), key=lambda w: w.get("number", 0)):
        wt = ws.get("worktree") or {}
        checkout = wt.get("checkout_path", "")
        if not checkout:
            # plain workspaces: use the repo the panes are working in, if any
            cwds = [p.get("cwd") for p in panes if p["workspace_id"] == ws["workspace_id"] and p.get("cwd")]
            checkout = next(filter(None, (git_root(d) for d in cwds)), "")
        rows = []
        for pane in (p for p in panes if p["workspace_id"] == ws["workspace_id"]):
            pi = info.get(pane["pane_id"], {})
            pids = tree(pi.get("shell_pid", -1))
            fg = [p.get("name", "") for p in pi.get("foreground_processes", [])]
            agent = agents.get(pane["pane_id"])
            rows.append({
                "pane": pane["pane_id"],
                "what": agent["agent"] if agent else (fg[0] if fg else "shell"),
                "title": (agent or {}).get("terminal_title_stripped", ""),
                "status": (agent or {}).get("agent_status", ""),
                "cpu": sum(procs[p][1] for p in pids),
                "mem_kb": sum(procs[p][2] for p in pids),
                "ports": sorted({port for p in pids for port in ports.get(p, [])}),
            })
        workspaces.append({
            "id": ws["workspace_id"],
            "number": ws.get("number"),
            "label": ws.get("label", ""),
            "branch": git_branch(checkout),
            "checkout": checkout,
            "linked": wt.get("is_linked_worktree", False),
            "repo": wt.get("repo_name", ""),
            "focused": ws.get("focused", False),
            "panes": rows,
            # compose stacks belong to the checkout they were started from
            "docker": docker.get(checkout, []),
            "env": env_local(checkout) if checkout else {},
        })
    return workspaces


def git_root(path):
    return run("git", "-C", path, "rev-parse", "--show-toplevel").strip()


def git_branch(path):
    return run("git", "-C", path, "branch", "--show-current").strip() if path else ""


def mem(kb):
    return f"{kb / 1048576:.1f}G" if kb >= 1048576 else f"{kb / 1024:.0f}M"


def short(path):
    return path.replace(HOME, "~", 1) if path else ""


def render(workspaces, color=True):
    c = (lambda code: code) if color else (lambda code: "")
    lines = []
    tot_cpu = sum(r["cpu"] for w in workspaces for r in w["panes"])
    tot_mem = sum(r["mem_kb"] for w in workspaces for r in w["panes"])
    dockers = [d for w in workspaces for d in w["docker"]]
    d_cpu, d_mem = sum(d[2] for d in dockers), sum(d[3] for d in dockers)
    lines.append(f"{c(BOLD)}Runtimes{c(RESET)}  {len(workspaces)} workspaces · panes {tot_cpu:.0f}% {mem(tot_mem)} · {len(dockers)} containers {d_cpu:.0f}% {mem(d_mem)}  {c(DIM)}{time.strftime('%H:%M:%S')}{c(RESET)}")
    for w in workspaces:
        mark = "▸" if w["focused"] else " "
        if w["linked"]:
            where = f"worktree of {w['repo']}"
        else:
            where = short(w["checkout"]) or "(no checkout)"
        branch = f" [{w['branch']}]" if w["branch"] and w["branch"] != w["label"] else ""
        lines.append("")
        lines.append(f"{mark}{c(BOLD)}{w['number']} {w['label']}{c(RESET)}{branch}  {c(DIM)}{where}{c(RESET)}")
        for k, v in w["env"].items():
            lines.append(f"    {c(DIM)}{k}={v}{c(RESET)}")
        for r in w["panes"]:
            status = r["status"] if r["status"] not in ("", "unknown") else ""
            st = f" {c(STATUS_COLOR.get(status, ''))}{status}{c(RESET)}" if status else ""
            title = f" {c(DIM)}{r['title']}{c(RESET)}" if r["title"] else ""
            ports = f"  :{' :'.join(map(str, r['ports']))}" if r["ports"] else ""
            lines.append(f"    {r['pane']:<7} {r['what']:<10}{st}{title}  {c(DIM)}{r['cpu']:.0f}% {mem(r['mem_kb'])}{c(RESET)}{ports}")
        for service, ports, cpu, m in w["docker"]:
            p = f"  :{' :'.join(map(str, ports))}" if ports else ""
            lines.append(f"    {c(DIM)}docker{c(RESET)}  {service:<10} {c(DIM)}{cpu:.0f}% {mem(m)}{c(RESET)}{p}")
    return "\n".join(lines)


ANSI = re.compile(r"\033\[[0-9;?]*[A-Za-z]")


def clip(line, width):
    """Cut a line to width visible chars, keeping escape codes intact."""
    out, seen, i = [], 0, 0
    while i < len(line) and seen < width:
        m = ANSI.match(line, i)
        if m:
            out.append(m.group())
            i = m.end()
        else:
            out.append(line[i])
            seen += 1
            i += 1
    return "".join(out) + RESET


def live():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    sys.stdout.write("\033[?25l")  # hide cursor
    try:
        tty.setcbreak(fd)
        while True:
            workspaces = collect()
            rows = shutil.get_terminal_size().lines
            cols = shutil.get_terminal_size().columns
            body = [clip(line, cols) for line in render(workspaces).splitlines()[: rows - 2]]
            sys.stdout.write("\033[H\033[2J" + "\n".join(body))
            sys.stdout.write(f"\n{DIM}q quit · r refresh · 1-9 focus workspace{RESET}")
            sys.stdout.flush()
            if select.select([sys.stdin], [], [], REFRESH_S)[0]:
                key = sys.stdin.read(1)
                if key in ("q", "\x1b"):
                    return
                if key.isdigit():
                    ws = next((w for w in workspaces if str(w["number"]) == key), None)
                    if ws:
                        run(HERDR, "workspace", "focus", ws["id"])
                        return
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        sys.stdout.write("\033[?25h\n")


if __name__ == "__main__":
    if "--once" in sys.argv:
        print(render(collect(), color=sys.stdout.isatty()))
    else:
        live()
