# 🌌 World of Noumenon

**A text-based multiplayer universe built in Elixir.**
Explore, chat, fight, and shape your destiny in a living distributed world powered by the BEAM.

---

## 🧠 Overview

**World of Noumenon** is a text-based MMORPG — a modern MUD — written in **Elixir**, leveraging the **Erlang VM’s** strengths in concurrency, fault-tolerance, and distributed computing.

Every entity — player, NPC, room, or world — is an independent process. Together they form a resilient, evolving universe.

---

## ✨ Features

### Core Gameplay
- **Persistent worlds and rooms** with dynamic descriptions.
- **Real-time multiplayer chat** (`say`, `emote`, `whisper`, etc.).
- **NPCs** with personalities, dialogues, and behaviors.
- **Combat system** with raids, bosses, debuffs, and healing.
- **Species, classes, skills, and spells.**
- **Procedural quest generation** (or hand-crafted stories).

### Player Systems
- **Accounts and characters** stored in PostgreSQL via Ecto.
- **Inventory and equipment management.**
- **Mail system** for player, user, and guild correspondence.
- **Admin tools** for world editing, spawning, and moderation.

### Guild System
- **Guild creation** with roles (Leader, Officer, Member).
- **Guild bank** for shared gold and items.
- **Guild mail**, **MOTD**, and **news board** for coordination.
- **Auditable transaction logs** and permissions.

### Architecture
- **OTP Supervision Tree** for players, rooms, and worlds.
- **Horde** and **libcluster** support for multi-node scaling.
- **ETS caching** for hot data (sessions, inventories, etc.).
- **Fully text-based interface**, accessible via Telnet or LiveText console.

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-------------|
| Language | [Elixir](https://elixir-lang.org) |
| Database | [PostgreSQL](https://www.postgresql.org) via [Ecto](https://hexdocs.pm/ecto) |
| Concurrency | OTP processes (BEAM) |
| Distribution | Horde / Libcluster |
| Storage | Ecto + ETS |
| Interface | Telnet / CLI |
| Testing | ExUnit |

---

> Noumenon is the unseen realm
>
> where language shapes existence
>
> and every word births a cosmos.
