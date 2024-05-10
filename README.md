# gepetto-dev-container

Devcontainer setup was initially created for the AGIMUS project.

This setup provides a devcontainer for ROS 2 Humble with predefined VS Code plugins and autocompletion for VS Code for C++ and Python, including ROS paths.

## Install docker and set up VS Code

To start the devcontainer first install Docker following this [guide](https://docs.docker.com/engine/install/ubuntu/).
Next, follow this [tutorial](https://docs.docker.com/engine/install/linux-postinstall/) on how to set up the access rights so `sudo` is no longer required to run docker.

And finally install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension in your VS Code.

## Start the devcontainer

You can start the dev container in several ways.

The simplest option is automatic. VS Code will show you, in the lower-right corner, a following window.

<div align="center">
  <img src="./resources/bottom_right_img.png" width=500 />
</div>

The second option is by pressing `F1` and typing `Dev Containers` and selecting `Rebuild and Reopen in Container...` if you want to restart it or `Attach to Running Container...` if you would like to log it to as already started container.

<div align="center">
  <img src="./resources/cetner_f1.png" width=500 />
</div>

The last option starts by clicking the green square with arrows in the lower-left corner of the VS Code. And then in the new pop-up window, select `Reopen in Container`.

<div align="center">
  <p float="center">
    <img src="./resources/bottom_left.png" height="180" />
    <img src="./resources/center_from_bottom_left.png" height="180" /> 
  </p>
</div>

Due to user access rights, VS Code will prompt you to type in `sudo` password. This is due to walk-round to have non-root access to `/dev/dri/*` devices to obtain hardware acceleration for GUI applications.

## Additional scripts

Inside the container in the main ROS workspace directory, there are scripts `setup.sh` and `build.sh`. They simplify the pipeline by scripting installation of the dependencies with `rosdep` and run `colcon build` commands.

## GPU support for rendering

The dev container automatically sets up access to NVIDIA GPUs. Commands such as `nvidia-smi` are available and work as long as NVIDIA drivers are installed on the host system. For neural network inference everything should be automatic, yet for GUI applications additional variables are required. For more information see [devcontainer.json](./.devcontainer/devcontainer.json) file.

