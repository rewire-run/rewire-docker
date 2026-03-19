<h1 align="center">
  <a href="https://www.rewire.run/">
    <img alt="rewire" src="https://github.com/user-attachments/assets/d22f718a-87e7-4740-aa1e-1716fc3f7328">
  </a>
</h1>

<p align="center">
  <a href="https://github.com/rewire-run/rewire-docker/actions/workflows/build.yaml">
    <img alt="Build" src="https://github.com/rewire-run/rewire-docker/actions/workflows/build.yaml/badge.svg">
  </a>
  <a href="https://github.com/rewire-run/rewire/releases/latest">
    <img alt="Version" src="https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Freleases.rewire.run%2Fversion.txt&search=%5Cd%2B%5C.%5Cd%2B%5C.%5Cd%2B&label=version&prefix=v&color=green">
  </a>
  <a href="https://ghcr.io/rewire-run/rewire">
    <img alt="GHCR" src="https://img.shields.io/badge/ghcr.io-rewire--run%2Frewire-blue">
  </a>
</p>

# rewire-docker

Docker images for [Rewire](https://github.com/rewire-run/rewire) — a drop-in ROS 2 bridge for
[Rerun](https://rerun.io).

Try rewire without installing anything on your host. Each image includes ROS 2, rewire, zenohd,
and zenoh-bridge-ros2dds.

## Images

| Tag | ROS 2 | Architecture |
|-----|-------|-------------|
| `ghcr.io/rewire-run/rewire:humble` | Humble | amd64, arm64 |
| `ghcr.io/rewire-run/rewire:jazzy` | Jazzy | amd64, arm64 |

## Quick Start

```bash
docker pull ghcr.io/rewire-run/rewire:humble

docker run --rm ghcr.io/rewire-run/rewire:humble rewire --version
docker run --rm ghcr.io/rewire-run/rewire:humble rewire types
```

## Docker Compose

Three networking scenarios are available via profiles:

```bash
docker compose --profile dds up            # DDS multicast (default ROS 2)
docker compose --profile zenoh up          # Full Zenoh (rmw_zenoh_cpp + router)
docker compose --profile zenoh-bridge up   # DDS nodes + zenoh-bridge-ros2dds
```

Each profile starts a talker node and rewire, saving a recording to `./data/recording.rrd`.

## Running with Your Own Nodes

Start a ROS 2 node inside the container:

```bash
docker run --rm --network host ghcr.io/rewire-run/rewire:humble \
    ros2 run demo_nodes_cpp talker
```

In another terminal, bridge to Rerun:

```bash
docker run --rm --network host ghcr.io/rewire-run/rewire:humble \
    rewire record --all
```

## Save a Recording

```bash
docker run --rm --network host -v $(pwd)/data:/data ghcr.io/rewire-run/rewire:humble \
    rewire record --all --save /data/recording.rrd
```

## X11 Forwarding (Linux)

```bash
xhost +local:docker
docker run --rm --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    ghcr.io/rewire-run/rewire:humble rewire record --all
```

## Interactive Shell

```bash
docker run --rm -it --network host ghcr.io/rewire-run/rewire:humble bash
```

ROS 2 is already sourced. Run any ROS 2 or rewire command directly.

## What's Inside

| Component | Source | Purpose |
|-----------|--------|---------|
| ROS 2 Humble/Jazzy | OSRF apt | Run nodes, replay bags |
| rewire | [GitHub Releases](https://github.com/rewire-run/rewire/releases) | Bridge ROS 2 topics to Rerun |
| zenohd | conda-forge via pixi | Zenoh router |
| zenoh-bridge-ros2dds | [Eclipse Zenoh](https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds) | DDS ↔ Zenoh bridge |
| demo_nodes_cpp | OSRF apt | Example talker/listener |
| tf2_ros | OSRF apt | TF transform broadcasting |
| rmw_cyclonedds_cpp | OSRF apt | CycloneDDS RMW |
| rmw_fastrtps_cpp | OSRF apt | FastDDS RMW |
| rmw_zenoh_cpp | OSRF apt | Zenoh RMW |

## End-to-End Test

Verify everything works in one command:

```bash
docker run --rm ghcr.io/rewire-run/rewire:humble bash -c '
    ros2 run demo_nodes_cpp talker &
    sleep 3
    timeout 10 rewire record --all --save /tmp/test.rrd 2>&1
    kill %1 2>/dev/null
    SIZE=$(stat -c%s /tmp/test.rrd 2>/dev/null || echo 0)
    if [ "$SIZE" -gt 100 ]; then
        echo "PASS: recording is $SIZE bytes"
    else
        echo "FAIL: recording too small or missing"
        exit 1
    fi
'
```

## Build Locally

```bash
docker build -t rewire:humble .
docker build --build-arg ROS_DISTRO=jazzy -t rewire:jazzy .
```

### Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `ROS_DISTRO` | `humble` | ROS 2 distribution |
| `REWIRE_VERSION` | `0.2.6` | Rewire release version |
| `ZENOH_BRIDGE_VERSION` | `1.8.0` | zenoh-bridge-ros2dds version |
