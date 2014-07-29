require 'spec_helper'

describe "Cluster.kcluster" do
  it "runs kcluster for the given data" do
    nclusters = 3
    # First data set
    weight = [1,1,1,1,1]
    data   = [[ 1.1, 2.2, 3.3, 4.4, 5.5],
              [ 3.1, 3.2, 1.3, 2.4, 1.5],
              [ 4.1, 2.2, 0.3, 5.4, 0.5],
              [12.1, 2.0, 0.0, 5.0, 0.0]]
    mask   = [[ 1, 1, 1, 1, 1],
             [ 1, 1, 1, 1, 1],
             [ 1, 1, 1, 1, 1],
             [ 1, 1, 1, 1, 1]]


    clusterids, error, nfound = Cluster.kcluster data, :clusters  => nclusters,
                                                       :mask      => mask,
                                                       :weight    => weight,
                                                       :transpose => false,
                                                       :passes    => 100,
                                                       :method    => 'a',
                                                       :dist      => 'e'

    expect(clusterids.size).to be(data.size)
    correct = [0,1,1,2]
    mapping = nclusters.times.map { |n| clusterids[correct.index(n)] }
    clusterids.each_with_index do |ci, i|
      expect(ci).to be(mapping[correct[i]])
    end
  end

  it "runs kcluster for a second set of data" do
    nclusters = 3
    weight = [1,1]
    data = [ [ 1.1, 1.2 ],
             [ 1.4, 1.3 ],
             [ 1.1, 1.5 ],
             [ 2.0, 1.5 ],
             [ 1.7, 1.9 ],
             [ 1.7, 1.9 ],
             [ 5.7, 5.9 ],
             [ 5.7, 5.9 ],
             [ 3.1, 3.3 ],
             [ 5.4, 5.3 ],
             [ 5.1, 5.5 ],
             [ 5.0, 5.5 ],
             [ 5.1, 5.2 ]]

    mask = [ [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ],
             [ 1, 1 ]]

    clusterids, error, nfound = Cluster.kcluster data, :clusters  => nclusters,
                                                       :mask      => mask,
                                                       :weight    => weight,
                                                       :transpose => false,
                                                       :passes    => 100,
                                                       :method    => 'a',
                                                       :dist      => 'e'

    expect(clusterids.size).to be(data.size)

    correct = [0, 0, 0, 0, 0, 0, 1, 1, 2, 1, 1, 1, 1]
    mapping = nclusters.times.map { |n| clusterids[correct.index(n)] }
    clusterids.each_with_index do |ci, i|
      expect(ci).to be(mapping[correct[i]])
    end
  end

  it "raises ArgumentError if passed inconsistent data" do
    expect {
      Cluster.kcluster [[1,2,3], [1,2,3,4]], {}
    }.to raise_error(ArgumentError, "expected 3 columns, row has 4")
  end

  it "will use default options" do
    data = [[1,1,1], [10,10,0], [0,0,0]]
    clusterids, error, nfound = Cluster.kcluster(data, :passes => 1000)

    expect(clusterids).to be_kind_of(Array)
    expect([[0, 1, 0], [1, 0, 1]]).to include(clusterids)
  end
end