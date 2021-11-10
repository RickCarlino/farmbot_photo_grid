import express from 'express';
import { Farmbot, uuid } from 'farmbot';
import atob from "atob";
import { readFileSync, writeFileSync } from 'fs';
import { networkInterfaces } from 'os';

global.atob = atob;

// === DETERMINE LAN IP ADDRESS ===
// Farmbot will talk to this server over the LAN.
// The code below will try to guess your IP address.
// You can just as easily delete this code and hardcode the
// value of
const nets = networkInterfaces();
const ip_addresses = [];

for (const name of Object.keys(nets)) {
  for (const net of nets[name]) {
    // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
    if (net.family === 'IPv4' && !net.internal) {
      ip_addresses.push(net.address);
    }
  }

}

console.log("HERE ARE YOUR DEVICE IP ADDRESS(es): ")
console.log("I will assume the first one is correct.")
console.dir(ip_addresses);

// === TOKEN GENERATION ===
// This helper will synchronously read an arbitrary file path.
// We use it to 1) Read the FarmBot token. 2) Read the gird.lua
// file to upload it to the device (covered later).
function readFile(path) {
  return new TextDecoder().decode(readFileSync(path)).trim();
}
// Your token is stored as a text file:
const token = readFile("./token");
const fb = new Farmbot({ token });

// ==== START WEB SERVER ===
// The device will upload photos via HTTP.
// We are using the Express webserver framework.
const app = express();
const port = 4567;
// If you want to hard code your server's IP address, do it here:
const server_address = `http://${ip_addresses[0]}:${port}/photo`;

// Configure Express to allow very large file uploads (photos)
app.use(express.raw({ limit: "99mb" }))

// Perform an HTTP POST to /photo to upload a new photo.
// Put the filename in an HTTP header named `file_path`.
// See grid.lua for more information.
app.post('/photo', (req, res) => {
  writeFileSync("photos_with_z/" + req.headers["file_path"], req.body);
  console.log("Got a post request.");
  res.send("OK");
  res.end();
});


// I added this route to catch all other HTTP requests.
// If you see the message below, you made a mistake.
app.get('*', (req, res) => {
  res.send('Perform a post request to /photo .');
  res.end();
});

await fb.connect();

// === UPLOAD grid.lua TO THE DEVICE ===
// This code does not use or expect any sequences.
// It copy/pastes Lua code to the device directly (no sequence).
fb.send({
  kind: "rpc_request",
  args: {
    label: uuid(),
    priority: 100
  },
  body: [
    {
      kind: "lua",
      args: {
        lua: `
        server_address = "${server_address}"
        ${readFile("./grid.lua")}
        `
      }
    }
  ]
}).then(() => { }, () => {
  console.error("RPC ERROR");
});

app.listen(port, () => {
  console.log(`Awaiting requests at ${server_address}`);
})

