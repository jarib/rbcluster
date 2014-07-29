require 'spec_helper'

describe "Cluster.kmedoids" do
  it "should calculate kmedoids from a distance matrix" do
    data = [[2.2, 3.3, 4.4],
           [2.1, 1.4, 5.6],
           [7.8, 9.0, 1.2],
           [4.5, 2.3, 1.5],
           [4.2, 2.4, 1.9],
           [3.6, 3.1, 9.3],
           [2.3, 1.2, 3.9],
           [4.2, 9.6, 9.3],
           [1.7, 8.9, 1.1]]

    mask = [[1, 1, 1],
           [1, 1, 1],
           [0, 1, 1],
           [1, 1, 1],
           [1, 1, 1],
           [0, 1, 0],
           [1, 1, 1],
           [1, 0, 1],
           [1, 1, 1]]

    weight = [2.0, 1.0, 0.5]
    matrix = Cluster.distancematrix data, :mask => mask, :weight => weight

    matrix[1][0].should be_within(0.001).of(1.243)

    matrix[2][0].should be_within(0.001).of(25.073)
    matrix[2][1].should be_within(0.001).of(44.960)

    matrix[3][0].should be_within(0.001).of(4.510)
    matrix[3][1].should be_within(0.001).of(5.924)
    matrix[3][2].should be_within(0.001).of(29.957)

    matrix[4][0].should be_within(0.001).of(3.410)
    matrix[4][1].should be_within(0.001).of(4.761)
    matrix[4][2].should be_within(0.001).of(29.203)
    matrix[4][3].should be_within(0.001).of(0.077)

    matrix[5][0].should be_within(0.001).of(0.040)
    matrix[5][1].should be_within(0.001).of(2.890)
    matrix[5][2].should be_within(0.001).of(34.810)
    matrix[5][3].should be_within(0.001).of(0.640)
    matrix[5][4].should be_within(0.001).of(0.490)

    matrix[6][0].should be_within(0.001).of(1.301)
    matrix[6][1].should be_within(0.001).of(0.447)
    matrix[6][2].should be_within(0.001).of(42.990)
    matrix[6][3].should be_within(0.001).of(3.934)
    matrix[6][4].should be_within(0.001).of(3.046)
    matrix[6][5].should be_within(0.001).of(3.610)

    matrix[7][0].should be_within(0.001).of(8.002)
    matrix[7][1].should be_within(0.001).of(6.266)
    matrix[7][2].should be_within(0.001).of(65.610)
    matrix[7][3].should be_within(0.001).of(12.240)
    matrix[7][4].should be_within(0.001).of(10.952)
    matrix[7][5].should be_within(0.001).of(0.000)
    matrix[7][6].should be_within(0.001).of(8.720)

    matrix[8][0].should be_within(0.001).of(10.659)
    matrix[8][1].should be_within(0.001).of(19.056)
    matrix[8][2].should be_within(0.001).of(0.010)
    matrix[8][3].should be_within(0.001).of(16.949)
    matrix[8][4].should be_within(0.001).of(15.734)
    matrix[8][5].should be_within(0.001).of(33.640)
    matrix[8][6].should be_within(0.001).of(18.266)
    matrix[8][7].should be_within(0.001).of(18.448)

    clusterid, error, nfound = Cluster.kmedoids matrix, :passes => 1000

    clusterid[0].should == 5
    clusterid[1].should == 5
    clusterid[2].should == 2
    clusterid[3].should == 5
    clusterid[4].should == 5
    clusterid[5].should == 5
    clusterid[6].should == 5
    clusterid[7].should == 5
    clusterid[8].should == 2

    error.should be_within(0.001).of(7.680)
  end
end