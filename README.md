# 📹 Topsvision / Xiongmai CCTV VMS Console & CLI Gateway

A modern, standalone **Video Management System (VMS) Workstation & CLI Gateway** designed for **Topsvision / Xiongmai CCTV DVRs and NVRs**. Runs seamlessly in any modern browser without legacy ActiveX or NPAPI plugins.

---

## 📑 Table of Contents
1. [Target Device & Hardware Profile](#-target-device--hardware-profile)
2. [Host NVR Archive & VOD Playback Architecture](#-host-nvr-archive--vod-playback-architecture)
3. [Key Features](#-key-features)
4. [Command-Line Interface (CLI) Reference](#-command-line-interface-cli-reference)
5. [Web VMS Workstation Console](#-web-vms-workstation-console)
6. [Quick Start & Installation](#-quick-start--installation)
7. [API Endpoints](#-api-endpoints)

---

## 🔍 Target Device & Hardware Profile

Tested against **Topsvision / Xiongmai DVR / NVR** devices:

| Component | Specification / Detected Service |
| :--- | :--- |
| **HTTP Server (Port 80)** | `uc-httpd/1.0.0` (Legacy web management interface) |
| **RTSP Server (Port 554)** | `Topsvision Server v2.1` (Supports Main, Sub, and Host VOD streams) |
| **P2P Cloud Port (33051)** | Active P2P Cloud service tunnel for XVRView / XMEye mobile client |
| **NetSDK Control Port (34567)** | Topsvision / Xiongmai proprietary Sofia NetSDK socket (PTZ & commands) |
| **Hardware Debug (9530)** | HiSilicon SoC hardware debug protocol |
| **CMS Media Port (9527)** | Xiongmai CMS desktop media streaming socket |
| **Remote Console (5800)** | VNC remote HTTP console |
| **Video Encoding** | **H.265 / HEVC Main Profile** (90,000 Hz RTP clock rate) |
| **Audio Encoding** | **G.711 A-law (PCMA)** (8,000 Hz mono) |
| **Physical Channels** | Physical camera inputs with HD 720p (1280x720) video + audio |
| **Digital Slots** | Multi-channel NVR digital expansion slots |

---

## 📼 Host NVR Archive & VOD Playback Architecture

### Native Host RTSP VOD Seeking
The NVR host provides native access to its 24/7 internal storage archive via RTSP VOD URL parameters:
```
rtsp://<user>:<password>@<host>:554/H264/ch<channel>/vod/av_stream?starttime=YYYYMMDDTHHMMSSZ
```

The gateway exposes full native support for host archive operations:
1. **Interactive 24-Hour Timeline Scrubbing:** Clicking any timecode on the Web VMS 24-hour timeline immediately routes a seek request to `/api/archive/host_seek` and switches the video tile to the host NVR's VOD playback stream.
2. **Direct Host Archive Export (`--export-host-archive`):** Clips can be downloaded directly from the NVR host storage and saved into universal MP4 files (H.265 video with AAC audio) via CLI or the Web UI.
3. **Local On-Demand Recording:** Real-time capture with instantaneous segmentation and playback.
4. **HTTP 206 Partial Content Streaming:** Smooth seekable playback with HTML5 video controls and variable playback speeds.

---

## ✨ Key Features

- **Zero Hardcoded Secrets:** No hardcoded IP addresses, serials, or passwords in Git-tracked files. All settings are configurable via Web UI, CLI flags, environment variables, or local ignored config.
- **Native Host Archive Seeking & Export:** Scrub the 24-hour timeline or run CLI commands to extract footage directly from the host NVR hard drive.
- **Native Sofia Protocol PTZ (Port 34567):** Raw TCP socket OPPTZControl framing to control pan, tilt, zoom, and iris without external binaries.
- **P2P Cloud Tunnel & QR Pairing (Port 33051):** Real-time socket probing, mobile pairing QR code generation for XVRView / XMEye, and Cloud ID discovery.
- **Suppressed HEVC POC Warnings:** OS-level descriptor redirection eliminates repetitive libavcodec C warnings (`Could not find ref with POC ...`) from console output.
- **Live AAC Audio Streaming:** Converts RTSP G.711 A-law audio into native browser-compatible AAC in real-time.
- **Flexible Grid Layouts:** Instant switching between Single (1 camera), Quad (4 cameras), and Full (8 cameras) views.

---

## 💻 Command-Line Interface (CLI) Reference

The gateway script `camera_viewer.py` provides a rich set of command-line tools:

### 1. Diagnostic Hardware Probe (`--probe`)
Scans target ports, checks RTSP channels, and prints a structured hardware diagnostic table:
```bash
python3 camera_viewer.py --probe --host <nvr_ip> --user admin --password <password> --channels 8
```

### 2. P2P Cloud Diagnostic Probe (`--p2p-probe`)
Tests P2P cloud daemon on port 33051, executes binary packet handshake, resolves hardware MAC address, and detects device Cloud ID:
```bash
python3 camera_viewer.py --p2p-probe --host <nvr_ip>
```

### 3. Terminal QR Code for Mobile Pairing (`--p2p-qr`)
Renders the device Cloud ID and an ISO-standard ASCII QR Code directly in your terminal for instant scanning with the XVRView or XMEye mobile apps:
```bash
python3 camera_viewer.py --p2p-qr --host <nvr_ip>
```

### 4. High-Resolution Snapshot (`--snapshot`)
Captures a crisp frame directly from any camera channel and saves it as a JPEG:
```bash
# Capture HD snapshot from Channel 1
python3 camera_viewer.py --snapshot --host <nvr_ip> --user admin --password <password> --channel 1 --output cam1_snap.jpg

# Capture snapshot from Channel 2
python3 camera_viewer.py --snapshot --host <nvr_ip> --user admin --password <password> --channel 2 --output cam2_snap.jpg
```

### 5. Direct Clip Recording (`--record`)
Records a live video clip of specified duration with universal H.265 + AAC audio muxing:
```bash
# Record 30 seconds from Channel 1 (HD Main Stream)
python3 camera_viewer.py --record --host <nvr_ip> --user admin --password <password> --channel 1 --duration 30 --output clip_cam1.mp4

# Record 60 seconds from Channel 2 (Sub Stream)
python3 camera_viewer.py --record --host <nvr_ip> --user admin --password <password> --channel 2 --duration 60 --stream sub --output clip_cam2.mp4
```

### 6. Export Clip Directly from Host NVR Archive (`--export-host-archive`)
Downloads recorded footage directly from the host NVR storage via RTSP VOD:
```bash
# Download 60 seconds of footage starting at 18:00:00 today from Channel 1
python3 camera_viewer.py --export-host-archive --host <nvr_ip> --user admin --password <password> --channel 1 --time 18:00:00 --duration 60 --output host_ch1_1800.mp4
```

### 7. List Archive Recordings (`--list-archive`)
Lists all indexed local recordings with timestamps, durations, and sizes:
```bash
python3 camera_viewer.py --list-archive
```

### 8. Launch VMS Web Server (`--serve`)
Runs the full web workstation console:
```bash
# Start server on default port 8080
python3 camera_viewer.py --serve

# Start server pre-configured with host credentials
python3 camera_viewer.py --host <nvr_ip> --user admin --password <password> --web-port 8080 --no-browser

# Start server in P2P Cloud mode
python3 camera_viewer.py --p2p --cloud-id <cloud_id> --host <nvr_ip> --user admin --password <password> --web-port 8080 --no-browser
```

### 9. Mobile App & Cloud Web Pairing Guide
* **Vendor Web Portal:** [http://www.topscloud.net/doc/page/login.jsp](http://www.topscloud.net/doc/page/login.jsp)
* **Device Cloud ID / Serial:** Auto-detected dynamically with `--p2p-probe` or printed on the bottom device label.
* **Mobile Apps:** **XVRView** / **XMEye** (iOS & Android) — tap `+` -> `Add by Serial` and scan the terminal QR code generated by `--p2p-qr`.
* **Hardware Ports:**
  - `33051/tcp`: P2P Cloud Tunnel (XVRView / XMEye tunnel daemon)
  - `34567/tcp`: Xiongmai / TopsCloud NetSDK Sofia Media Protocol (PTZ)
  - `554/tcp`: RTSP H.264/H.265 video & AAC audio streams (Main, Sub, VOD)
  - `80/tcp`: uc-httpd Web Administration Interface

---

### CLI Parameters Summary
| Argument | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `--probe` | Flag | `False` | Run NVR hardware diagnostic scan |
| `--p2p-probe` | Flag | `False` | Probe P2P port 33051 and auto-detect Cloud ID |
| `--p2p-qr` | Flag | `False` | Print terminal ASCII QR Code for XVRView / XMEye |
| `--snapshot` | Flag | `False` | Capture single frame JPEG |
| `--record` | Flag | `False` | Record live stream clip to MP4 file |
| `--export-host-archive` | Flag | `False` | Download clip directly from host NVR archive storage |
| `--list-archive`| Flag | `False` | Display local recordings table |
| `--serve` | Flag | `True` | Run the VMS HTTP web server |
| `--host` | String | None | Target NVR IP or hostname |
| `--port` | Int | `554` | NVR RTSP port |
| `--p2p` | Flag | `False` | Connect via P2P Cloud tunnel mode |
| `--p2p-port` | Int | `33051` | NVR P2P / Cloud tunnel port |
| `--cloud-id` | String | Auto | Device P2P Cloud ID / Serial Number |
| `--cloud-server`| String | `www.topscloud.net` | P2P Cloud service server |
| `--web-port` | Int | `8080` | Local VMS web interface port |
| `--user` | String | None | RTSP username |
| `--password` | String | None | RTSP password |
| `--channels` | Int | `8` | Total NVR channels |
| `--channel` | Int | `1` | Camera channel (1..8) |
| `--stream` | String | `main` | Stream profile (`main`, `sub`, `vod`) |
| `--time` | String | None | Start time for host archive export (`HH:MM:SS` or ISO) |
| `--duration` | Int | `30` | Recording duration in seconds |
| `--output` | Path | Auto | Output filename for snapshot/recording |
| `--archive-dir`| Path | `/tmp/cctv_archive` | Local archive storage path |
| `--clean` | Flag | `False` | Clear saved credentials and reset |
| `--no-browser` | Flag | `False` | Do not launch browser automatically |

---

## 🖥 Web VMS Workstation Console

Access the web interface at:
* **Local Machine:** [http://localhost:8080/](http://localhost:8080/)
* **Local LAN:** `http://<your_local_ip>:8080/`

### Features
1. **Connection Modal:**
   - Dedicated fields for Host, RTSP Port, P2P Cloud Port (33051), Channels, Username, Password.
   - **⚡ Test RTSP** and **⚡ Test P2P (33051)** buttons to verify connectivity before connecting.
   - Click the top-bar host badge anytime to re-open settings.
2. **P2P Cloud Live Telemetry:**
   - Sidebar displays live status of the P2P Cloud Tunnel (Port 33051) with real-time ping latency and QR pairing modal.
3. **Interactive 24-Hour Timeline:**
   - Displays 24-hour trackbar with time tooltip (`HH:MM:SS`).
   - Click anywhere to seek host NVR archive playback or save 1-minute / 5-minute clips directly from host storage.
4. **Native PTZ Controller (Port 34567):**
   - 8-way directional pan/tilt controls with zoom and stop commands over the Sofia NetSDK protocol.
5. **On-Demand Recording (REC):**
   - Click `⏺ REC` in the top navbar to start recording the active camera with a live seconds counter.
6. **Live Audio Stream:**
   - Click `🔊` to toggle live audio from the camera's microphone.

---

## 🚀 Quick Start & Installation

### 1. Install Dependencies
```bash
cd /path/to/topsvision-cctv-gateway
pip install -r requirements.txt
```

### 2. Start VMS Workstation Server
```bash
./run.sh
```

Or pass any CLI arguments directly:
```bash
./run.sh --probe --host <nvr_ip>
./run.sh --snapshot --channel 1
```

---

## 📡 API Endpoints

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/` | `GET` | Main VMS Web Console HTML |
| `/video_feed?channel=N&quality=main\|sub\|vod` | `GET` | Multipart MJPEG stream (Live or Host VOD) |
| `/audio_feed?channel=N` | `GET` | Real-time AAC audio stream |
| `/snapshot?channel=N` | `GET` | Instant JPEG image capture |
| `/api/session` | `GET` | Current connection session status |
| `/api/status?channel=N` | `GET` | Stream telemetry (FPS, resolution, status) |
| `/api/p2p/status` | `GET` | Live P2P Cloud tunnel connectivity & ping latency |
| `/api/p2p/info` | `GET` | Full P2P Cloud session state, MAC, Cloud ID, and pairing data |
| `/api/p2p/qrcode` | `GET` | ISO QR Code PNG image for mobile pairing (XVRView / XMEye) |
| `/api/p2p/detect` | `POST` | Auto-detect device Cloud ID from hardware profile |
| `/api/p2p/connect` | `POST` | Connect to DVR via P2P Cloud tunnel mode |
| `/api/p2p/test` | `POST` | Test connection to P2P Cloud daemon (33051) |
| `/api/test_connection` | `POST` | Test RTSP handshake with given credentials |
| `/api/login` | `POST` | Authenticate and connect to NVR |
| `/api/archive/host_seek?channel=N&time=HH:MM:SS` | `GET` | Seek Host NVR archive VOD stream to timestamp |
| `/api/archive/host_export?channel=N&duration=S&time=HH:MM:SS` | `GET` | Export and download MP4 clip directly from Host NVR |
| `/api/archive/list?channel=N` | `GET` | List all recorded clips for channel |
| `/api/archive/record` | `POST` | Start or stop channel recording |
| `/api/archive/status?channel=N` | `GET` | Check if channel is currently recording |
| `/api/archive/stream?file=filename.mp4` | `GET` | Stream MP4 with HTTP 206 partial seeking |
| `/api/archive/download?file=filename.mp4` | `GET` | Download raw MP4 recording file |
| `/api/archive/export?channel=N&duration=S` | `GET` | Generate and download quick clip |
| `/api/ptz?channel=N&action=start\|stop&cmd=CMD` | `GET` | Native Sofia NetSDK Pan-Tilt-Zoom control (Port 34567) |
