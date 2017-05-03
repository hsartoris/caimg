import matplotlib
matplotlib.use("agg")

import matplotlib.pyplot as plt
import numpy as np

dataIdx = 1

data = np.genfromtxt(str(dataIdx) + ".csv", delimiter=',')

for i in range(0, len(data)):
	plt.plot(data[i])

plt.savefig(str(dataIdx) + ".png", dpi=200)
