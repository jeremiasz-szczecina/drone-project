import math


# PID class
class UavPID:
	# predefined kp, ki, kd for x, y, z, yaw
	PREDEFINED_KP = [0.69, 0.69, 8.0, 1.0] # x, y, z, yaw
	PREDEFINED_KI = [0.0005, 0.0005, 0.0001, 0.0002] # x, y, z, yaw
	PREDEFINED_KD = [40.0, 40.0, 22.0, 10.0] # x, y, z, yaw

	# variables
	_errors_list = [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
	_errors_count = [2, 2, 2, 2]

	_kp = [0.0, 0.0, 0.0, 0.0] # x, y, z, yaw
	_ki = [0.0, 0.0, 0.0, 0.0] # x, y, z, yaw
	_kd = [0.0, 0.0, 0.0, 0.0] # x, y, z, yaw
	#
	_max_param_value = [1.0, 1.0, 1.0, 1.0] # x, y, z, yaw

	_s = 0.0

	# constructor(s)
	def __init__(self, kp=None, ki=None, kd=None):
		if kp is None:
			self._kp = self.PREDEFINED_KP
		else:
			self._kp = kp

		if ki is None:
			self._ki = self.PREDEFINED_KI
		else:
			self._ki = ki

		if kd is None:
			self._kd = self.PREDEFINED_KD
		else:
			self._kd = kd
	
	# functions
	def __determine_param(self, param):
		item_no = 0
		if param == 'X':
			item_no = 0
		elif param == 'Y':
			item_no = 1
		elif param == 'Z':
			item_no = 2
		elif param == 'YAW':
			item_no = 3

		return item_no

	def calculate(self, param, horizon=-1):
		item_no = self.__determine_param(param)

		if self._errors_count[item_no] >= 2:
			if (horizon == -1) or (horizon > self._errors_count[item_no]):
				horizon = self._errors_count[item_no]

			U = (self._kp[item_no] * self._errors_list[item_no][-1]) + (self._kd[item_no] * (self._errors_list[item_no][-1] - self._errors_list[item_no][-2]))

			if ((self._errors_list[item_no][-2] > self._max_param_value[item_no]) and (self._errors_list[item_no][-1] > 0)) or ((self._errors_list[item_no][-2] < -self._max_param_value[item_no]) and (self._errors_list[item_no][-1] < 0)):
				self._s = 0.0
			else:
				#for el in range(horizon):
				self._s += self._errors_list[item_no][-1]

			result = U + (self._ki[item_no] * self._s)

			if result > self._max_param_value[item_no]:
				result = self._max_param_value[item_no]
			elif result < -self._max_param_value[item_no]:
				result = -self._max_param_value[item_no]

			return result

	def insert_error_value_pair(self, param, value_set, value_read):
		item_no = self.__determine_param(param)
		self._errors_list[item_no].append((value_set - value_read))
		self._errors_count[item_no] += 1

	def insert_error_value(self, param, value):
		item_no = self.__determine_param(param)
		self._errors_list[item_no].append(value)
		self._errors_count[item_no] += 1

	def reset_errors_list(self):
		self._errors_list = [[0.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
		self._s = 0.0
		self._errors_count = [2, 2, 2, 2]

