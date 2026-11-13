# libghostty-gtk

A GTK4 terminal widget on [libghostty-vt](https://lib.ghostty.org/), Ghostty's
terminal engine, with the part of VTE's `Vte.Terminal` API that elementary
Terminal uses, under the namespace `GhosttyGtk`. Porting an app off VTE is then mostly
a rename; see the `libghostty-gtk` branch of
[arsfeld/elementary-terminal](https://github.com/arsfeld/elementary-terminal).

libghostty-gtk draws with GtkSnapshot and does its own PTY, input (keyboard, IME, mouse,
paste), selection, OSC 52 clipboard, search and URL matching. libghostty-vt
provides parsing and terminal state only.

## Installing

On elementary OS 8, `libghostty-gtk-1-0` and `libghostty-gtk-dev` are in the
signed apt repo at [arsfeld.github.io/pantheon-apt](https://arsfeld.github.io/pantheon-apt),
built by this repo's CI on every push to `master`. Those packages link
libghostty-vt statically, so nothing else is needed.

## Building

Needs Meson >= 1.0, Vala, GLib, GTK 4, Pango and libghostty-vt 1.0
(`pkg-config libghostty-vt`). Where no package provides libghostty-vt 1.0,
`ci/build-libghostty-vt.sh` builds it into `/opt/libghostty-vt`, and
`-Dghostty_static=true` links it into the library.

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
