# Example of kmedoids clusterization
#
# For more info look at
# - https://github.com/jarib/rbcluster/blob/master/ext/rbcluster/rbcluster.c#L291
# - https://github.com/jarib/rbcluster/blob/master/ext/rbcluster/cluster.c#L2729
# - chapter 8.1.2 page 28 http://bonsai.hgc.jp/~mdehoon/software/cluster/cluster.pdf

require 'rbcluster'

dm = [
  [],           #
  [12],         # distance between 2nd and 1st
  [76, 5],      # distance between 3rd and 1st, 3rd and 2nd
  [50, 10, 42]  # distance between 4th and 1st, 4th and 2nd, 4th and 3rd
]

# for more info look at https://github.com/jarib/rbcluster/blob/master/ext/rbcluster/rbcluster.c#L291
result = RbCluster.kmedoids(dm, passes: 100, clusters: 2)

p result # => [[0, 1, 1, 1], 15.0, 65]
