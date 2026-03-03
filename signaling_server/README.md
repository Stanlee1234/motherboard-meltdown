# Motherboard Meltdown — Signaling Server

A minimal Node.js WebSocket signaling server for future WebRTC peer-to-peer support.

> **Note:** The game currently uses ENet (UDP) for direct connections. This server is scaffolded for a future WebRTC upgrade that will allow browser / cross-platform play without needing to know the host's IP address.

## Running Locally

```bash
cd signaling_server
npm install
npm start
# Server listens on ws://localhost:8911
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT`   | `8911`  | WebSocket port to listen on |

## Protocol

All messages are JSON objects with a `type` field.

### Client → Server

| `type`          | Fields            | Description                              |
|-----------------|-------------------|------------------------------------------|
| `create_room`   | `room_id: string` | Host creates a room with a unique ID     |
| `join_room`     | `room_id: string` | Guest joins an existing room             |
| `offer`         | `sdp: string`     | WebRTC SDP offer (relayed to peer)       |
| `answer`        | `sdp: string`     | WebRTC SDP answer (relayed to peer)      |
| `ice_candidate` | `candidate: obj`  | ICE candidate (relayed to peer)          |

### Server → Client

| `type`               | Description                              |
|----------------------|------------------------------------------|
| `room_created`       | Confirms room creation for the host      |
| `room_joined`        | Confirms the guest joined                |
| `peer_joined`        | Sent to the host when a guest joins      |
| `peer_disconnected`  | Sent when the other peer closes          |
| `error`              | Something went wrong (`message` field)   |

## Deploying to Render.com

1. Push your repo to GitHub.
2. Go to [render.com](https://render.com) → **New Web Service**.
3. Connect the repo, select the `signaling_server` folder as the root.
4. Build command: `npm install`
5. Start command: `npm start`
6. Render sets `PORT` automatically — no changes needed.

## Deploying to Glitch.com

1. Go to [glitch.com](https://glitch.com) → **New Project → Import from GitHub**.
2. Glitch expects `package.json` at the repo root; copy `signaling_server/` contents to the Glitch project root.
3. Glitch sets `PORT` via environment automatically.
