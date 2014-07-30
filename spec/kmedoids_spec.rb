require 'spec_helper'

describe "Cluster.kmedoids" do
  it "calculates kmedoids from a distance matrix" do
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

    expect(matrix[1][0]).to be_within(0.001).of(1.243)

    expect(matrix[2][0]).to be_within(0.001).of(25.073)
    expect(matrix[2][1]).to be_within(0.001).of(44.960)

    expect(matrix[3][0]).to be_within(0.001).of(4.510)
    expect(matrix[3][1]).to be_within(0.001).of(5.924)
    expect(matrix[3][2]).to be_within(0.001).of(29.957)

    expect(matrix[4][0]).to be_within(0.001).of(3.410)
    expect(matrix[4][1]).to be_within(0.001).of(4.761)
    expect(matrix[4][2]).to be_within(0.001).of(29.203)
    expect(matrix[4][3]).to be_within(0.001).of(0.077)

    expect(matrix[5][0]).to be_within(0.001).of(0.040)
    expect(matrix[5][1]).to be_within(0.001).of(2.890)
    expect(matrix[5][2]).to be_within(0.001).of(34.810)
    expect(matrix[5][3]).to be_within(0.001).of(0.640)
    expect(matrix[5][4]).to be_within(0.001).of(0.490)

    expect(matrix[6][0]).to be_within(0.001).of(1.301)
    expect(matrix[6][1]).to be_within(0.001).of(0.447)
    expect(matrix[6][2]).to be_within(0.001).of(42.990)
    expect(matrix[6][3]).to be_within(0.001).of(3.934)
    expect(matrix[6][4]).to be_within(0.001).of(3.046)
    expect(matrix[6][5]).to be_within(0.001).of(3.610)

    expect(matrix[7][0]).to be_within(0.001).of(8.002)
    expect(matrix[7][1]).to be_within(0.001).of(6.266)
    expect(matrix[7][2]).to be_within(0.001).of(65.610)
    expect(matrix[7][3]).to be_within(0.001).of(12.240)
    expect(matrix[7][4]).to be_within(0.001).of(10.952)
    expect(matrix[7][5]).to be_within(0.001).of(0.000)
    expect(matrix[7][6]).to be_within(0.001).of(8.720)

    expect(matrix[8][0]).to be_within(0.001).of(10.659)
    expect(matrix[8][1]).to be_within(0.001).of(19.056)
    expect(matrix[8][2]).to be_within(0.001).of(0.010)
    expect(matrix[8][3]).to be_within(0.001).of(16.949)
    expect(matrix[8][4]).to be_within(0.001).of(15.734)
    expect(matrix[8][5]).to be_within(0.001).of(33.640)
    expect(matrix[8][6]).to be_within(0.001).of(18.266)
    expect(matrix[8][7]).to be_within(0.001).of(18.448)

    clusterid, error, nfound = Cluster.kmedoids matrix, :passes => 1000

    expect(clusterid[0]).to eq(5)
    expect(clusterid[1]).to eq(5)
    expect(clusterid[2]).to eq(2)
    expect(clusterid[3]).to eq(5)
    expect(clusterid[4]).to eq(5)
    expect(clusterid[5]).to eq(5)
    expect(clusterid[6]).to eq(5)
    expect(clusterid[7]).to eq(5)
    expect(clusterid[8]).to eq(2)

    expect(error).to be_within(0.001).of(7.680)
  end
end