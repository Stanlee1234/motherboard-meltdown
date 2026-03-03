"use strict";

const { WebSocketServer } = require("ws");

const PORT = process.env.PORT || 8911;
const wss = new WebSocketServer({ port: PORT });

// rooms[roomId] = { host: ws, guest: ws | null }
const rooms = {};

wss.on("connection", (ws) => {
  ws.roomId = null;
  ws.role = null;

  ws.on("message", (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw);
    } catch {
      return;
    }

    switch (msg.type) {
      case "create_room": {
        const id = msg.room_id;
        if (!id) return;
        if (rooms[id]) {
          ws.send(JSON.stringify({ type: "error", message: "Room already exists" }));
          return;
        }
        rooms[id] = { host: ws, guest: null };
        ws.roomId = id;
        ws.role = "host";
        ws.send(JSON.stringify({ type: "room_created", room_id: id }));
        console.log("Room created:", id);
        break;
      }

      case "join_room": {
        const id = msg.room_id;
        if (!id || !rooms[id]) {
          ws.send(JSON.stringify({ type: "error", message: "Room not found" }));
          return;
        }
        if (rooms[id].guest) {
          ws.send(JSON.stringify({ type: "error", message: "Room is full" }));
          return;
        }
        rooms[id].guest = ws;
        ws.roomId = id;
        ws.role = "guest";
        ws.send(JSON.stringify({ type: "room_joined", room_id: id }));
        // Notify host
        const host = rooms[id].host;
        if (host && host.readyState === 1) {
          host.send(JSON.stringify({ type: "peer_joined" }));
        }
        console.log("Room joined:", id);
        break;
      }

      // Relay SDP offer / answer / ICE candidates between peers
      case "offer":
      case "answer":
      case "ice_candidate": {
        const room = ws.roomId ? rooms[ws.roomId] : null;
        if (!room) return;
        const target = ws.role === "host" ? room.guest : room.host;
        if (target && target.readyState === 1) {
          target.send(JSON.stringify(msg));
        }
        break;
      }

      default:
        break;
    }
  });

  ws.on("close", () => {
    const id = ws.roomId;
    if (!id || !rooms[id]) return;
    const room = rooms[id];
    const other = ws.role === "host" ? room.guest : room.host;
    if (other && other.readyState === 1) {
      other.send(JSON.stringify({ type: "peer_disconnected" }));
    }
    delete rooms[id];
    console.log("Room closed:", id);
  });
});

console.log(`Signaling server running on port ${PORT}`);
