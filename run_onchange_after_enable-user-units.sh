#!/bin/sh
# Enable the systemd user units the desktop session depends on. chezmoi reruns
# this whenever the list below changes; `enable` is idempotent, and units are
# not started here (no --now) so an apply never disturbs the running session.
#
# The session runs under uwsm, so graphical-session.target is reached and the
# units wanted by it start with the compositor. pipewire/wireplumber come
# enabled by their packages' presets and are not listed. kmonad@ is left out on
# purpose: its thinkpad and thinkpad-strict instances are mutually exclusive and
# are switched at runtime by ~/.config/kmonad/cycle-mods.

set -eu

systemctl --user daemon-reload
systemctl --user enable \
    hypridle.service \
    hyprpaper.service \
    hyprpolkitagent.service \
    kanshi.service \
    kanshi-resume.service
