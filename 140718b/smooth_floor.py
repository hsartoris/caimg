import numpy as np

#floors data to 0
window = 15

dataMax = 72
desample = True

for filename in range(1, dataMax + 1):
	data = np.genfromtxt(str(filename) + ".csv", delimiter=',')
	data[0] = data[0] - np.amin(data[0])
	output = np.array([np.convolve(data[0][::2], np.ones(window)/window, mode='valid')])
	for i in range(1, len(data)):
		data[i] = data[i] - np.amin(data[i])
		output = np.append(output, np.array([np.convolve(data[i][::2], np.ones(window)/window, mode='valid')]), axis=0)
	np.savetxt("smooth/" + str(filename) + ".csv", output, delimiter=',')
print("Done")
