import numpy as np
import matplotlib.pyplot as plt

filename = "1"

window = 10

data = np.genfromtxt(filename + ".csv", delimiter=',')
smooth = np.convolve(data[0], np.ones(window)/window, mode='valid')
output = np.array([smooth])
for i in range(1, len(data)):
	smooth = np.convolve(data[i], np.ones(10)/10, mode='valid')
	output = np.append(output, np.array([smooth]), axis=0)
	#data[i] = smooth

np.savetxt(filename + "_smooth.csv", output,  delimiter=',')

print(output)
