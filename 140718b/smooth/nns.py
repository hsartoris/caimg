from sklearn.neighbors import NearestNeighbors
import numpy as np

dataIdx = 1

data = np.genfromtxt(str(dataIdx) + ".csv", delimiter=',')

nbrs = NearestNeighbors(n_neighbors = 5, algorithm='ball_tree').fit(data)
distances, indices = nbrs.kneighbors(data)

print(distances)
print(indices)
