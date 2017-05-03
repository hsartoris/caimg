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

data = np.genfromtxt(str(num) + ".csv", delimiter=',')
#data = StandardScaler().fit_transform(data)

#bandwidth = cluster.estimate_bandwidth(data, quantile=0.3)
connectivity = kneighbors_graph(data, n_neighbors=7, include_self=False)
connectivity = .5 * (connectivity + connectivity.T)

data_clustered = cluster.AgglomerativeClustering(linkage="complete", affinity="manhattan", n_clusters=7, connectivity=connectivity)

data_clustered.fit(data)
y_pred = data_clustered.labels_.astype(np.int)
np.savetxt(str(num) + "_clusters.csv", y_pred, delimiter=',')

print(y_pred)
plt.hist(y_pred)

#plt.scatter(data[:, 0], data[:, 1], color = colors[y_pred].tolist(), s=10)

plt.savefig(str(num) + "_hist.png", dpi=200)
