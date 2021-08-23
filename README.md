# drone-project
# **Autonomous drone model steering (Bebop 2) using MATLAB + ROS/Gazebo architecture**
Project made during 6th semester (02.2021 - 06.2021) of my studies with my friend as a warm-up before working on an actual thesis. 
**My contribution involved**:
* tuning drone PID controllers (ISE criterium) in a cascade structure for each axis (x, y, z, yaw angle), so when we wanted the drone to reach 3 meters - it *did* reach 3 meters with only a few milimiters precision
* implementing flight trajectory and option to gather and plot all the important data
* wrapping it up in simple GUI
* preparing final documentation


**Project environment:**
* Ubuntu 18.04 LTS (virtualized, VMware)
* MATLAB R2021a + ROS Toolbox
* ROS Melodic, Gazebo/Sphinx
* [bebop_autonomy](https://bebop-autonomy.readthedocs.io/en/latest/) - ROS Driver for Parrot Bebop 1.0/2.0 
* g2r_repeater node - .pyc file **provided by our project supervisor**, translates drone's pose from Gazebo to ROS

![ROS structure in rqt_graph](https://i.imgur.com/uOfaEgF.png)
*g2r_repeater* node's task is to translate drone position from Gazebo to ROS - it's because drone and Gazebo do operate on a different coordinate system. It publishes this pose in /repeater/bebop2/pose/info topic with 55-60 Hz frequency. Global matlab node (described in every detail below) takes the data, processes them in */goToGoal* topic and then publishes received info to the adequate topics, delivered by aforementioned *bebop_autonomy* driver.

![MATLAB structure block diagram](https://drive.google.com/file/d/1j9N5FaIaUyvdo121zmW8AdwqLL-_X2v6/view?usp=sharing)
