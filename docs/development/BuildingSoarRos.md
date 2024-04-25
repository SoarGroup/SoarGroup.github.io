---
date: 2020-08-19 
authors: 
    - jboggs
tags:
    - ROS
    - compile
    - how-to
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/forum/help/sml/
287-build-soar-with-ros -->

# Build Soar with ROS

## Requirements

-   Ubuntu 18.04.4 LTS Bionic **THIS IS NOT OPTIONAL. NO OTHER LINUX DISTRO WORKS**
-   Relatively recent GPU **YOUR COMPUTER MUST HAVE A DISPLAY**
-   ROS Melodic **ONLY MELODIC WILL WORK**
-   Gazebo 9 **MUST BE 9**
-   Point Cloud Library version 1.8.1 **Must be 1.8.1**

ROS Installation (from <http://wiki.ros.org/melodic/Installation/Ubuntu>):

```Bash
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update
sudo apt install ros-melodic-desktop-full
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

Point Cloud Library should also be installed. Run sudo apt install libpcl-dev to
make sure.

## Download and Build Soar

```Bash
git clone https://github.com/SoarGroup/Soar.git -b svs_overhaul
sudo apt install build-essential swig openjdk-8-jdk python-all-dev
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOAR_HOME:/opt/ros/melodic/lib/
export CPATH=$CPATH:/usr/include/pcl-1.8/:/opt/ros/melodic/include/
cd Soar
python2 scons/scons.py all --use-ros
```

If you want Python 3 support, replace step 4 with:

```Bash
which python3
```

Copy the file path returned

```Bash
python2 scons/scons.py all --use-ros --python=<insert/path/copied/above>
```

Recommended: If you want to use Lizzie's svs_utils ROS package to make a world
with a Fetch robot, follow these steps: Install the Fetch ROS and Gazebo
packages: sudo apt install ros-melodic-fetch-ros ros-melodic-fetch-gazebo Create
a catkin workspace: mkdir ~/svs_utils_ws/src

```Bash
cd ~/svs_utils_ws
catkin_make
cd src
git clone https://[your_username]@bitbucket.org/emgoeddel/svs_util.git (Ask Lizzie for access to the Bitbucket)
cd ..
catkin_make
echo "source ~/svs_util_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc
```
