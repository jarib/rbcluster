require 'rbcluster'

data = [
  [1, 1, 0],
  [1, 0, 0],
  [0, 0, 0]
]

labels, error, nfound = Cluster.kcluster(data, :clusters => 2)
p [labels, error, nfound]