import numpy as np

window = 10

dataMax = 72

for filename in range(1, dataMax + 1):
	data = np.genfromtxt(str(filename) + ".csv", delimiter=',')
	output = np.array([np.convolve(data[0], np.ones(window)/window, mode='valid')])
	for i in range(1, len(data)):
		output = np.append(output, np.array([np.convolve(data[i], np.ones(window)/window, mode='valid')]), axis=0)
	np.savetxt("smooth/" + str(filename) + ".csv", output, delimiter=',')
print("Done")
