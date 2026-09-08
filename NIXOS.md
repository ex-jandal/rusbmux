# rusbmux on NixOS

Drop-in `usbmuxd` replacement in pure Rust.

## What you get

- **package** — the `rusbmux` daemon binary (`pkgs.rusbmux` / `default.nix`)
- **overlay** — exposes `pkgs.rusbmux`
- **NixOS module** — `services.rusbmux` systemd service
- works with **flakes** and **classic (non-flake) configs**

---

## With flakes

- Add the input:

  ```nix
  rusbmux.url = "github:abdullah-albanna/rusbmux";
  ```

- In `configuration.nix` (must receive `inputs`):

  ```nix
  imports = [ inputs.rusbmux.nixosModules.default ];
  services.rusbmux.enable = true;
  ```

- That's it: the module applies its own overlay, so `pkgs.rusbmux` is also
  available anywhere in your config (`environment.systemPackages = [ pkgs.rusbmux ];`).

---

## Without flakes

- Fetch the repo in `configuration.nix` and wire overlay + module:

  ```nix
  let
    rusbmux-src = builtins.fetchGit {
      url = "https://github.com/abdullah-albanna/rusbmux";
      ref = "main";
    };
  in {
    imports = [ "${rusbmux-src}/nixos-module.nix" ];
    nixpkgs.overlays = [ (import "${rusbmux-src}/overlay.nix") ];
    services.rusbmux.enable = true;
  }
  ```

- Or just build the package: `import "${rusbmux-src}/default.nix" { inherit pkgs; }`
- Pin to a specific commit for reproducibility:

  ```nix
  rusbmux-src = builtins.fetchGit {
    url = "https://github.com/abdullah-albanna/rusbmux";
    rev = "<commit-sha>";
  };
  ```

- Needs nixpkgs with **Rust ≥ 1.85** (edition 2024) — use a recent
  `nixos-unstable`/`nixos-26.11+`.

---

## Options

| Option        | Type       | Default                          | Description                     |
| ------------- | ---------- | -------------------------------- | ------------------------------- |
| `enable`      | boolean    | `false`                          | Enable the systemd service.     |
| `package`     | package    | `pkgs.rusbmux`                   | Which rusbmux package to run.   |
| `extraArgs`   | list of strings | `[]`                          | Extra CLI args for the daemon.  |

```nix
services.rusbmux = {
  enable = true;
  extraArgs = [ "--socket" "/run/usbmuxd" ];
};
```

---

## Service behavior

- runs as `root` via systemd (`systemd.services.rusbmux`)
- socket at `/var/run/usbmuxd` (mode `0666`)
- pairing records in `/var/lib/lockdown` (`StateDirectory=lockdown`)
- `Conflicts=usbmuxd.service`
- apply with `sudo nixos-rebuild switch --flake .#host`
- check: `systemctl status rusbmux` / `ls -l /var/run/usbmuxd`

---

## Manual use (no service)

- `nix run github:abdullah-albanna/rusbmux -- --help`
- `nix shell github:abdullah-albanna/rusbmux`

---

## Troubleshooting

- `usbmuxd.service` already running → disable it (units conflict).
- Clients can't connect → socket missing at `/var/run/usbmuxd`; check service status.
- Non-root USB access → the service runs as root, so nothing needed. For library
  mode as an unprivileged user, add a udev rule granting write access to
  `/dev/bus/usb/*`.

---

## License

Apache-2.0 or MIT, at your option.