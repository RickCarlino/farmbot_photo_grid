
import axios from 'axios';
import express from 'express';
import { Farmbot, uuid } from 'farmbot';
import atob from "atob";
import { readFileSync, writeFileSync } from 'fs';
import { networkInterfaces } from 'os';

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

global.atob = atob;

function readFile(path) {
  return new TextDecoder().decode(readFileSync(path)).trim();
}

const token = readFile("./token");
const fb = new Farmbot({ token });
const app = express();
const port = 4567;
const server_address = `http://${ip_addresses[0]}:${port}/photo`;

app.use(express.raw({ limit: "99mb" }))

app.post('/photo', (req, res) => {
  writeFileSync(req.headers["file_path"], req.body);
  console.log("Got a post request.");
  res.send("OK");
  res.end();
});

app.get('*', (req, res) => {
  res.send('Perform a post request to /photo .');
  res.end();
});

await fb.connect();
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

