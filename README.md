# gepetto-dev-container

Devcontainer setup was initially created for the AGIMUS project.

This setup provides a devcontainer for ROS 2 Humble with predefined VS Code plugins and autocompletion for VS Code for C++ and Python, including ROS paths.

## Additional scripts

Inside the container in the main ROS workspace directory, there are scripts `setup.sh` and `build.sh`. They simplify the pipeline by scripting installation of the dependencies with `rosdep` and run `colcon build` commands.
