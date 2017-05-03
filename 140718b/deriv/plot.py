import matplotlib
matplotlib.use("agg")

import matplotlib.pyplot as plt
import numpy as np

dataMax = 72

for num in range(1, dataMax + 1):
	plt.figure(num)
	data = np.genfromtxt(str(num) + ".csv", delimiter=',')
	for i in range(0, len(data)):
		plt.plot(data[i])
	plt.savefig(str(num) + ".png", dpi=200)
	print(num/72)
