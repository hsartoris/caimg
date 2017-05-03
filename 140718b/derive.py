import numpy as np

#floors data to 0
window = 15

dataMax = 72
desample = 1

def arrayDerivative(a):
	out = np.ones(len(a)-1)
	for i in range(0, len(a)-1):
		out[i] = a[i+1] - a[i]
	return out

def arraySmoothed(a, winLen, mode):
	return np.convolve(a, np.ones(winLen)/winLen, mode=mode)

for filename in range(1, dataMax + 1):
	data = np.genfromtxt(str(filename) + ".csv", delimiter=',')
	#data[0] = data[0] - np.amin(data[0])
	#output = np.array([np.convolve(data[0][::desample], np.ones(window)/window, mode='valid')])
	output = np.array([arrayDerivative(arraySmoothed(data[0], window, 'valid'))])
	for i in range(1, len(data)):
		#data[i] = data[i] - np.amin(data[i])
		#output = np.append(output, np.array([np.convolve(data[i][::desample], np.ones(window)/window, mode='valid')]), axis=0)
		output = np.append(output, np.array([arrayDerivative(arraySmoothed(data[i], window, 'valid'))]), axis=0)
	np.savetxt("deriv/" + str(filename) + ".csv", output, delimiter=',')
print("Done")

