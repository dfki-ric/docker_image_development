# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A collection of bash scripts (no compiled code) for a docker-based development and release workflow, mainly for robotics projects (ROS, ROS 2, Rock). Projects **fork** this repo and keep their project-specific setup in the fork: `settings.bash`, `docker-compose.exec.bash.yml`, `startscripts/` and `image_setup/02_devel_image/`. Upstream changes get merged into those forks, so keep changes to these user-editable files minimal and backwards compatible.

## Commands

```bash
./exec.bash [execmode] [command|startscript]   # create/start the container and run a command (default: /bin/bash)
VERBOSE=true ./exec.bash ...                   # debug output; prints the resolved compose config when a container is created
INTERACTIVE=false ./exec.bash ...              # non-interactive (CI): no -i, renews changed containers without asking
./stop.bash [execmode]
./delete_container.bash [execmode]
./tools/generate_standalone_compose.bash [execmode] [stored tag]   # writes the standalone docker-compose.yml
```

Exec modes are `base devel frozen release CD stored` (`EXECMODES` in `.docker_scripts/variables.bash`). `stored` needs a tag from `.stored_images.txt`. Without a mode, `DEFAULT_EXECMODE` from `settings.bash` is used.

Image builds (each is a standalone script):
- `image_setup/01_base_images/build_<flavor>.bash` (all call `build_base_image.bash`)
- `image_setup/02_devel_image/build.bash`
- `image_setup/03_frozen_image/build.bash`, then `store.bash` for the `stored` exec mode
- `image_setup/04_release_image/build.bash`
- `image_setup/05_save_image/build.bash`

Tests use [bats](https://github.com/bats-core/bats-core) and need the images locally. The suite deletes existing containers (it asks first):
```bash
bash tools/test_suite/test_suite.bash                                         # base, devel, release
EXECMODE=base bats tools/test_suite/bats/exec_stop_delete_container.bats       # single exec mode
```
There is no linter; use `bash -n <script>` for syntax checks.

## Architecture

### exec.bash call chain

`exec.bash` sources `.docker_scripts/docker_commands.bash`, which sources `settings.bash`, `variables.bash`, `file_handling.bash`, `helper_functions.bash` and `run_args_to_compose.bash`. It then sources `.docker_scripts/exec.bash` and calls `init_docker $@`.

- **`.docker_scripts/exec.bash`** is sourced **without arguments**, so its `shift` / `set --` change the caller's positional parameters, which are then passed on as the command to run. It parses the exec mode and command, sets `IMAGE_NAME` (`set_image_name`), selects compose files for the mode and the X server type, and sets `CONTAINER_NAME`.
- **`set_compose_config`** completes the configuration:
  - GPU detection: `check_gpu`, cached as `has_gpu_support` in `.container_config.txt`
  - docker in container, ssh agent
  - translation of `ADDITIONAL_DOCKER_RUN_ARGS`
  - exporting the interpolation variables
  - icecc ports
  - validation

  `tools/generate_standalone_compose.bash` reuses exactly this setup without creating a container.
- **`init_docker`** then manages the container lifecycle.

`settings.bash` `export`s its values and is re-sourced by many scripts, so it overrides environment variables of the same name.

### Container configuration (docker compose)

- `docker-compose.exec.bash.yml`: the `workspace` service, using `${VAR}`s exported by exec.bash (`export_compose_variables`). Projects add their own run parameters and services here.
- `.docker_scripts/compose/*.yml`: fragments added with `add_compose_file` depending on exec mode and settings (mounts, ccache, X server mount/xpra, gpu/nvidia runtime, ssh agent, icecc, docker socket). Paths use `${ROOT_DIR}`.
- `ADDITIONAL_DOCKER_RUN_ARGS` (settings.bash) is translated by `run_args_to_compose.bash` into a compose fragment and passed via stdin (`-f -`). Unsupported docker run options abort exec.bash. To support a new option, add it to the `case` table there.
- All compose calls go through the `docker_compose` wrapper, which adds the project name, the `-f` list and the stdin fragment.
- Each container is its own compose project: `COMPOSE_PROJECT_NAME` is the sanitized `CONTAINER_NAME` (`<folder>-<execmode>-<md5 of repo path>`), so several checkouts and exec modes don't interfere.

### Container lifecycle

- The image entrypoint (`image_setup/01_base_images/entrypoint.bash`, default `CMD init_container`) changes the container user's UID/GID to the host's (`NUID`/`NGID`) on the **first start and then exits**. Later starts keep `/bin/bash` running (`tty`/`stdin_open`).
- exec.bash therefore runs:
  1. `docker compose create`
  2. `docker start -a` (the init run)
  3. `docker compose up -d --no-recreate`

  After that, all commands run via `docker exec -u dockeruser`, plus `check_init_workspace.bash`, iceccd, xpra and `SERVICES` startup.
- **Change detection:** an md5 of `docker compose config` is stored as `RUN_ARGS_<mode>` in `.container_config.txt` (generated state, gitignored), together with the image ID. `PRINT_*`, `SCRIPTSVERSION` and `DISPLAY` are masked out of the checksum. A mismatch prompts to renew the container. Values in the compose config that may legitimately change between calls must be masked in `generate_run_args_checksum`, or users get renew prompts.
- Containers created by older versions with plain `docker run` (no compose labels) are still started and removed by name. `stop.bash` and `delete_container.bash` find the container's compose project from its labels (`find_container_compose_project`).

### Standalone docker-compose.yml

`docker-compose.yml` is **generated** (gitignored) by `tools/generate_standalone_compose.bash`:
- It is the full resolved config of one exec mode with no variables. Paths are relative and `DISPLAY` is passed through.
- It uses the same project and container name as exec.bash, so `docker compose ps/logs/exec/stop/start` in the repo root act on the exec.bash container. `docker compose up` recreates that container if the config differs.
- `update_standalone_compose_file` (called from `init_docker`) regenerates it, for the mode named in its header, when the `# source checksum:` no longer matches `standalone_compose_source_checksum`. That checksum covers settings.bash, the compose files, the scripts, VERSION and the GPU cache.
- A `docker-compose.yml` without the generated header is never overwritten.

### Images

- **base** (`01_base_images`, published as `developmentimage/<flavor>:base`): contains the entrypoint, init scripts and `VERSION`.
- **devel** (`02_devel_image`, per project): built from `workspace_os_dependencies.txt` and `setup_workspace.bash`. `workspace/`, `home/` and `startscripts/` are mounted from the host. Base mode mounts the `02_devel_image` setup files, so the devel setup can be developed in a base container.
- **frozen** (`03_frozen_image`): the devel image with the workspace copied in.
- **release** (`04_release_image`): a minimal distro image containing only the executables and linked libraries collected by `collect_dependencies.bash`, which runs in the devel container.

Image names and registries come from `settings.bash` (`WORKSPACE_*_IMAGE`, `*_REGISTRY`, `check_registry_overrides`).

### Versioning

The first word of `VERSION` is the scripts version (semver). It is baked into base images as `/opt/VERSION`. The entrypoint compares it with the `SCRIPTSVERSION` env set by exec.bash and warns on mismatches; a major mismatch aborts. Changes to files in `image_setup/01_base_images/` only take effect after rebuilding the base images.

### Conventions

- Print through `$PRINT_WARNING` / `$PRINT_INFO` / `$PRINT_DEBUG`, never plain `echo`. These are set from `VERBOSE` / `SILENT` in `variables.bash` (`:` disables output) and also passed into the container for the entrypoint.
- Scripts derive `ROOT_DIR` from `BASH_SOURCE`, so they work from any working directory.
- `image_setup/05_save_image/build.bash` copies the runtime files (`.docker_scripts/`, `settings.bash`, `docker-compose.exec.bash.yml`, exec/stop/delete scripts) into an archive. New files needed at runtime must be added there.
- When adding exec modes, also update `autocomplete.me`.
