import sys
import numpy as np
import matplotlib.pyplot as plt

from sklearn import cluster
from sklearn.neighbors import kneighbors_graph
from sklearn.preprocessing import StandardScaler

if (len(sys.argv) != 2):
	print("bad args number")
	exit()
colors = np.array([x for x in 'bgrcmykbgrcmykbgrcmykbgrcmyk'])
colors = np.hstack([colors] * 20)

num = int(sys.argv[1])

clusters = 2

output = None
for i in range(1, num + 1):
	data = np.genfromtxt(str(i) + ".csv", delimiter=',')
	#data = StandardScaler().fit_transform(data)
	
	#bandwidth = cluster.estimate_bandwidth(data, quantile=0.3)
	connectivity = kneighbors_graph(data, n_neighbors=clusters, include_self=False)
	connectivity = .5 * (connectivity + connectivity.T)
	
	data_clustered = cluster.AgglomerativeClustering(linkage="complete", affinity="manhattan", n_clusters=clusters, connectivity=connectivity)
	
	data_clustered.fit(data)
	y_pred = data_clustered.labels_.astype(np.int)
	#max = np.amax(y_pred) + 1
	#if (i == 5):
	#	print(max)
	#	print(y_pred)
	#for j in range(0, max):
	#	y_pred[y_pred == j] = int(max + j)
	
	#if (i == 5): # testing leave me alone
	#	print(y_pred)
	#j = 0
	#for n in range(0, len(y_pred)):
	#	if (y_pred[n] >= max):
	#		y_pred[y_pred == y_pred[n]] = j
	#		j = j + 1
		#y_pred[y_pred == y_pred[j]] = j
	#print(j)
	#if (i == 5):
	#	print(y_pred)
	if (output == None):
		output = np.array([y_pred])
	else:
		output = np.append(output, np.array([y_pred]), axis=0)
	print(i)
np.savetxt("looming_clusters.csv", output[::3], delimiter=',')
np.savetxt("flash_clusters.csv", output[1::3], delimiter=',')
np.savetxt("scrambled_clusters.csv", output[2::3], delimiter=',')
np.savetxt("clusters.csv", output, delimiter=',')


#print(y_pred)
#plt.hist(y_pred)

#plt.scatter(data[:, 0], data[:, 1], color = colors[y_pred].tolist(), s=10)

#plt.savefig(str(num) + "_hist.png", dpi=200)
