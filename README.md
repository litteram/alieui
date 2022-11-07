> not much of an _ui_.

All files contained in this repository are released under [ISC
License](./LICENSE) unless otherwise noted.

---

Configuration file: `config.lua`. Edit it if you want to change something (eg. unitframes).

### modules [*](./modules)

- `macros.lua`: add two commands to silence the ui `/ass` `/aff`
  ```
  /aff
  /use 15
  /use 16
  /ass
  /cast RotatingBoomkinStarfire
  ```
- `map_pins.lua`: force opacity of the in-game blizz waypoint system to 100%, no
  need to hide it, show me that 7.1k yards! Add new command `/uway` and `/way` if
  TomTom is not loaded.
- `sell_poor.lua`: sell poor items to poor merchants (for some reasons they
  really like gray stuff)
- `fast_loot.lua`: make it fast so I don't have to look at it.
- `fade_actionbars.lua`: fade in/out all those pesky buttons
- `fade_ui.lua`: fade more things to hide the mess

### unitframes [*](./unitframes)

Minimalistic frames, _stolen_ from the extremely nice [sInterface](https://github.com/sbaildon/sInterface).
