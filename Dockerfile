ARG ROS_DISTRO=humble

FROM ros:${ROS_DISTRO}-ros-base

ARG ROS_DISTRO
ARG REWIRE_VERSION=0.2.6

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ros-${ROS_DISTRO}-demo-nodes-cpp \
    ros-${ROS_DISTRO}-tf2-ros \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ros-${ROS_DISTRO}-rmw-fastrtps-cpp \
    libgl1-mesa-glx libx11-6 libxcb1 libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pixi.sh/install.sh | PIXI_NO_PATH_UPDATE=1 bash \
    && /root/.pixi/bin/pixi global install -c conda-forge zenohd
ENV PATH="/root/.pixi/bin:${PATH}"

ARG ZENOH_BRIDGE_VERSION=1.8.0
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/* \
    && ARCH=$(uname -m) \
    && curl -fsSL "https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds/releases/download/${ZENOH_BRIDGE_VERSION}/zenoh-plugin-ros2dds-${ZENOH_BRIDGE_VERSION}-${ARCH}-unknown-linux-gnu-standalone.zip" \
    -o /tmp/bridge.zip \
    && unzip /tmp/bridge.zip -d /usr/local/bin/ \
    && rm /tmp/bridge.zip

RUN ARCH=$(uname -m) \
    && curl -fsSL "https://github.com/rewire-run/rewire/releases/download/v${REWIRE_VERSION}/rewire-${REWIRE_VERSION}-${ARCH}-unknown-linux-gnu.tar.gz" \
    | tar xz -C /usr/local/bin/

WORKDIR /

ENTRYPOINT ["bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash && exec \"$@\"", "--"]
CMD ["rewire", "--version"]
