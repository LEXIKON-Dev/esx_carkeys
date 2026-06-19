# esx_carkeys

A lightweight **vehicle key system** for **FiveM** with **ESX Legacy**. Players can steal, manage, and share keys, as well as lock and unlock vehicles — including animations, sound effects, and automatic key expiration when the vehicle despawns from the map.

---

## Features

- **Lock/Unlock** – Lock and unlock vehicles with a keypress (includes key fob animation & remote sound)
- **Key Menu** – Overview of all stored keys
- **Steal Keys** – Steal the key while sitting in a vehicle
- **Give Keys** – Pass a copy to a nearby player
- **Remove Keys** – Delete individual keys from your inventory
- **Job Keys** – Server event for faction/job vehicles
- **Auto Expiration** – Keys automatically expire when the vehicle no longer exists on the map
- **Multilingual** – German, English & Danish (easily extendable)

---

## Dependencies

| Resource       | Required |
|----------------|----------|
| [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy) | Yes |
| [mysql-async](https://github.com/brouznouf/fivem-mysql-async) | Yes (listed in `fxmanifest.lua`) |

---

## Recommended

For a complete vehicle experience, I recommend using **[esx_carlock](https://github.com/sprixGG/esx_carlock)** alongside this script.

`esx_carkeys` handles key stealing, sharing, and management — while `esx_carlock` adds ownership-based locking for vehicles purchased through `esx_vehicleshop`, including lock/unlock animations and smart proximity detection (locks the closest owned vehicle even when multiple are nearby).

**Setup:**
1. Install [esx_carlock](https://github.com/sprixGG/esx_carlock) in your resources folder
2. Add both resources to your `server.cfg`:
   ```cfg
   ensure esx_carlock
   ensure esx_carkeys
   ```

> **Note:** `esx_carlock` requires [esx_vehicleshop](https://github.com/esx-framework/esx_vehicleshop) in addition to ESX.

---

## Installation

1. Clone or download the repository
2. Place the folder in your `resources` directory, e.g.:
   ```
   resources/[carkeys]/esx_carkeys
   ```
3. Add to your `server.cfg`:
   ```cfg
   ensure esx_carkeys
   ```
4. Optional: Adjust language and key bindings in `config.lua` (see below)

---

## Controls

| Action           | Default Key | Command           |
|------------------|-------------|-------------------|
| Lock vehicle     | `G`         | `/carkeys_lock`   |
| Key menu         | `L`         | `/carkeys_menu`   |

Key bindings and commands can be changed in `config.lua`.

---

## Configuration

All settings are located in [`config.lua`](config.lua):

```lua
Config.Locale = 'en'              -- 'de', 'en' or 'dan'

Config.LockDistance = 10.0        -- Max distance to lock/unlock
Config.GiveKeyDistance = 3.0      -- Max distance to give a key

Config.Keys = {
    lock = 'g',                   -- Key binding for lock
    menu = 'l',                   -- Key binding for menu
}

Config.DespawnCheckInterval = 3000 -- Interval (ms) for key expiration check
```

---

## Developer API

### Give Job Key

From another server script, you can give a player a job key:

```lua
TriggerServerEvent('carkeys:giveJobKey', targetServerId, plate, vehicleName)
```

| Parameter        | Description                    |
|------------------|--------------------------------|
| `targetServerId` | Server ID of the target player |
| `plate`          | Vehicle license plate          |
| `vehicleName`    | Display name of the vehicle    |

---

## Languages

| Code  | Language | File               |
|-------|----------|--------------------|
| `de`  | German   | `locale/de.lua`    |
| `en`  | English  | `locale/en.lua`    |
| `dan` | Danish   | `locale/dan.lua`   |

To add a new language: create a locale file, register it in `fxmanifest.lua`, and set it in `Config.Locale`.

---

## Project Structure

```
esx_carkeys/
├── client/
│   └── main.lua          # Client logic (menu, lock, animation)
├── server/
│   └── main.lua          # Server logic (key management, despawn check)
├── locale/
│   ├── de.lua
│   ├── en.lua
│   ├── dan.lua
│   └── init.lua
├── config.lua
├── fxmanifest.lua
└── README.md
```

---

## Author

**LEXIKON** · Version `1.0.0`

---

## License

No license specified — please contact the author for reuse or add a suitable open-source license.
