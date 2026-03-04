# Gruvbox Material Rofi theme

A simple theme for **[rofi](https://github.com/davatorium/rofi)** based on **[Gruvbox Material](https://github.com/sainnhe/gruvbox-material)** by [@sainnhe](https://github.com/sainnhe).

![](screenshot.png)

## Setup

1. Copy <a href="gruvbox-material.rasi">gruvbox-material.rasi</a> file to `~/.config/rofi/gruvbox-material.rasi`
2. Add the following lines to your rofi config (`~/.config/rofi/config.rasi`):
```
configuration {
    display-ssh:    "";
    display-run:    "";
    display-drun:   "";
    display-window: "";
    display-combi:  "";
    show-icons:     true;
}

@theme "~/.config/rofi/gruvbox-material.rasi"
```
