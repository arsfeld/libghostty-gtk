# libghostty-gtk

A GTK4 terminal widget on [libghostty-vt](https://lib.ghostty.org/), Ghostty's
terminal engine, with the part of VTE's `Vte.Terminal` API that elementary
Terminal uses, under the namespace `GhosttyGtk`. Porting an app off VTE is then mostly
a rename; see the `libghostty-gtk` branch of
[arsfeld/elementary-terminal](https://github.com/arsfeld/elementary-terminal).

libghostty-gtk draws with GtkSnapshot and does its own PTY, input (keyboard, IME, mouse,
paste), selection, OSC 52 clipboard, search and URL matching. libghostty-vt
provides parsing and terminal state only.

## Building

Needs Meson >= 1.0, Vala, GLib, GTK 4, Pango and libghostty-vt 1.0
(`pkg-config libghostty-vt`).

```sh
meson setup build
meson compile -C build
meson test -C build   # widget tests need a Wayland display, e.g. weston --backend=headless
```

It installs the library `ghostty-gtk-1`, its VAPI and the GSettings schema
`io.github.arsfeld.ghostty-gtk`.

## Status

Experimental, used daily as elementary Terminal's engine on NixOS. The API
tracks what elementary Terminal needs and may change.

## License

GPL-3.0-or-later. See `COPYING`.
