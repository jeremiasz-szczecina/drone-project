#!/usr/bin/env python

import math
import csv
import rospy
import os
from std_msgs.msg import String
from std_msgs.msg import Empty
from std_msgs.msg import Float64
from geometry_msgs.msg import Twist
from sensor_msgs.msg import NavSatFix
from nav_msgs.msg import Odometry
from bebop_msgs.msg import Ardrone3PilotingStateAltitudeChanged
from bebop_msgs.msg import Ardrone3PilotingStateFlyingStateChanged
from tf.transformations import euler_from_quaternion
import tf

from enum import Enum
from modules.pid import UavPID

class DronesState(Enum):
	LANDED = 0
	TAKING_OFF = 1
	HOVERING = 2
	FLYING = 3
	LANDING = 4
	EMERGENCY = 5
	USERTAKEOFF = 6
	MOTOR_RAMPING = 7
	EMERGENCY_LANDING = 8


drones_state = DronesState.LANDED


# worlds coordinate system
class ReferenceSystemTransformer:
	def x(self, target_pos, current_pos):
		err_x = target_pos[0] - current_pos[0]
		err_y = target_pos[1] - current_pos[1]
		return err_x * math.cos(current_pos[3]) + err_y * math.sin(current_pos[3])

	def y(self, target_pos, current_pos):
		err_x = target_pos[0] - current_pos[0]
		err_y = target_pos[1] - current_pos[1]
		return err_y * math.cos(current_pos[3]) - err_x * math.sin(current_pos[3])


# global variables
action_takeoff = None
action_land = None
action_move = None
supervisor = None

PID_handler = None
PID_error_locked = True
RST_handler = None

target_pos = [0.0, 0.0, 0.0, 0.0]  # x, y, z, yaw
target_pos_norm = [0.0, 0.0, 0.0, 0.0]  # x, y, z, yaw
base_pos = [0.0, 0.0, 0.0, 0.0]  # x, y, z, yaw
current_pos = [0.0, 0.0, 0.0, 0.0]  # x, y, z, yaw

__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))


def state_callback(data):
	global drones_state
	drones_state = data.state


def odom_callback(data):
	global PID_handler
	global base_pos
	global target_pos
	global PID_error_locked
	global target_pos_norm
	global current_pos

	x_val = data.pose.pose.position.x
	y_val = data.pose.pose.position.y

	(ar, ap, yaw_val) = tf.transformations.euler_from_quaternion(
		[data.pose.pose.orientation.x, data.pose.pose.orientation.y, data.pose.pose.orientation.z,
		 data.pose.pose.orientation.w])

	current_pos[0] = (x_val * math.cos(yaw_val)) + (y_val * math.sin(yaw_val))
	current_pos[1] = (-x_val * math.sin(yaw_val)) + (y_val * math.cos(yaw_val))
	current_pos[2] = data.pose.pose.position.z
	current_pos[3] = yaw_val

	if PID_error_locked == False:
		PID_handler.insert_error_value_pair('X', target_pos[0], current_pos[0])
		PID_handler.insert_error_value_pair('Y', target_pos[1], current_pos[1])
		PID_handler.insert_error_value_pair('Z', target_pos[2], current_pos[2])
		PID_handler.insert_error_value_pair('YAW', target_pos[3], current_pos[3])


def dbg_callback(data):  # Z/YAW
	rospy.loginfo('New task has been received!')

	empty_msg = Empty()
	twist_msg = Twist()

	twist_msg.linear.x = 0
	twist_msg.linear.y = 0
	twist_msg.linear.z = 0
	twist_msg.angular.x = 0
	twist_msg.angular.y = 0
	twist_msg.angular.z = 0

	global RST_handler
	RST_handler = ReferenceSystemTransformer()

	rospy.loginfo('Bebop Take Off')
	action_takeoff.publish(empty_msg)
	global drones_state
	while not(drones_state == DronesState.HOVERING.value):
		continue

	global base_pos
	global target_pos
	global current_pos
	global PID_error_locked
	global target_pos_norm

	target_pos[0] = 0
	target_pos[1] = 0
	target_pos[2] = 0
	target_pos[3] = 0

	rate_yaw_test = rospy.Rate(90)
	result_file_h = open(os.path.join(__location__, "results.csv"), "w")
	iteration = 1

	for kp in range(1, 51, 2):
		for ki in range(1, 21, 1):
			for kd in range(5, 41, 1):
				n_kp = ((kp * 1.0) / 100)
				n_ki = ((ki * 1.0) / 10000)
				n_kd = kd

				PID_error_locked = True
				global PID_handler
				PID_handler = UavPID([0, 0, 0, n_kp], [0, 0, 0, n_ki], [0, 0, 0, n_kd])
				PID_error_locked = False

				pid_trigger = 0.008
				J_data = []
				J = 0.0
				D_data = []
				D = 0.0

				target_pos[3] = 2.0  # yaw
				PID_handler.reset_errors_list()
				rospy.loginfo('Bebop Move [#YAW]' + '[' + str(iteration) + ']')
				PID_result = 1.0
				loop_cond = 0

				while (abs(PID_result) > pid_trigger) or (loop_cond < 180):
					PID_result = PID_handler.calculate('YAW')
					J_data.append(abs(target_pos[3] - current_pos[3]))
					twist_msg.angular.z = PID_result
					action_move.publish(twist_msg)
					rate_yaw_test.sleep()
					loop_cond += 1
				D_data.append(abs(target_pos[3] - current_pos[3]))

				target_pos[3] = -2.5
				PID_handler.reset_errors_list()
				# rospy.loginfo('Bebop Move [#YAW]')
				PID_result = 1.0
				loop_cond = 0

				while (abs(PID_result) > pid_trigger) or (loop_cond < 180):
					PID_result = PID_handler.calculate('YAW')
					J_data.append(abs(target_pos[3] - current_pos[3]))
					twist_msg.angular.z = PID_result
					action_move.publish(twist_msg)
					rate_yaw_test.sleep()
					loop_cond += 1
				D_data.append(abs(target_pos[3] - current_pos[3]))

				target_pos[3] = 3.0
				PID_handler.reset_errors_list()
				# rospy.loginfo('Bebop Move [#YAW]')
				PID_result = 1.0
				loop_cond = 0

				while (abs(PID_result) > pid_trigger) or (loop_cond < 180):
					PID_result = PID_handler.calculate('YAW')
					J_data.append(abs(target_pos[3] - current_pos[3]))
					twist_msg.angular.z = PID_result
					action_move.publish(twist_msg)
					rate_yaw_test.sleep()
					loop_cond += 1
				D_data.append(abs(target_pos[3] - current_pos[3]))

				target_pos[3] = 0.0
				PID_handler.reset_errors_list()
				# rospy.loginfo('Bebop Move [#YAW]')
				PID_result = 1.0
				loop_cond = 0

				while (abs(PID_result) > pid_trigger) or (loop_cond < 180):
					PID_result = PID_handler.calculate('YAW')
					J_data.append(abs(target_pos[3] - current_pos[3]))
					twist_msg.angular.z = PID_result
					action_move.publish(twist_msg)
					rate_yaw_test.sleep()
					loop_cond += 1
				D_data.append(abs(target_pos[3] - current_pos[3]))

				for j in J_data:
					J += j

				for d in D_data:
					D += d

				iteration += 1

				rospy.loginfo('Kp = ' + str(n_kp) + '\t' + 'Ki = ' + str(n_ki) + '\t' + 'Kd = ' + str(n_kd) + '\n' + 'J = ' + str(J) + '\t' + 'D = ' + str(D) + '\n')
				result_file_h.write(str(n_kp) + '\t' + str(n_ki) + '\t' + str(n_kd) + '\t' + str(J) + '\t' + str(D) + '\n')
				result_file_h.flush()

	result_file_h.close()
	rospy.sleep(5)

	rospy.loginfo('Bebop Land')
	action_land.publish(empty_msg)

	while not(drones_state == DronesState.LANDED.value):
		continue

	rospy.loginfo('Done!')


def bbp_controller():
	rospy.init_node('bbp_controller', anonymous=True)

	global action_takeoff
	global action_land
	global action_move
	global supervisor

	state_changed = rospy.Subscriber('/bebop/states/ardrone3/PilotingState/FlyingStateChanged', Ardrone3PilotingStateFlyingStateChanged, state_callback)
	rospy.Subscriber('performance_testing', Empty, dbg_callback)
	action_takeoff = rospy.Publisher('/bebop/takeoff', Empty, queue_size=10)
	action_land = rospy.Publisher('/bebop/land', Empty, queue_size=10)
	action_move = rospy.Publisher('/bebop/cmd_vel', Twist, queue_size=1000)
	odom_topic_handler = rospy.Subscriber('/repeater/bebop2/pose/info', Odometry, odom_callback)

	rospy.loginfo('Node activated!')
	rospy.spin()
	rospy.loginfo('Node closed!')


if __name__ == '__main__':
	bbp_controller()

