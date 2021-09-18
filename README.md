# What is this?

An ExpressJS server that tells FarmBot to take a photo via grid every X mm and save the resulting images to your harddrive (instead of the API).

**Make sure you understand the source code before running the software.**

# Install

```
git clone https://github.com/RickCarlino/farmbot_photo_grid.git
cd farmbot_photo_grid
npm install
```

# Setup

1. Ensure FarmBot can access your laptop via LAN.
1. Create a file in the project directory called `token`.
1. Paste your farmbot token into the `token` file.
1. Change the value of (`step_size`, `start_x`, `end_x`, `start_y`, `end_y`) in `grid.lua`.
1. Run `node index.mjs`
1. Farmbot will immediately start taking photos.
1. Delete or move *.jpg files as needed and re-run.
