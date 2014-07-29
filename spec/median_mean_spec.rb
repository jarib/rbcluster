require 'spec_helper'

describe "Cluster.{median,mean}" do
  let(:data) {
    [
      [ 34.3, 3, 2 ],
      [ 5, 10, 15, 20],
      [ 1, 2, 3, 5, 7, 11, 13, 17],
      [ 100, 19, 3, 1.5, 1.4, 1, 1, 1],
    ]
  }

  it "calculates the median" do
    expect(Cluster.median(data[0])).to be(3.0)
    expect(Cluster.median(data[1])).to be(12.5)
    expect(Cluster.median(data[2])).to be(6.0)
    expect(Cluster.median(data[3])).to be(1.45)
  end

  it "calculates the mean" do
    expect(Cluster.mean(data[0])).to be_within(0.001).of(13.1)
    expect(Cluster.mean(data[1])).to be_within(0.001).of(12.5)
    expect(Cluster.mean(data[2])).to be_within(0.001).of(7.375)
    expect(Cluster.mean(data[3])).to be_within(0.001).of(15.988)
  end
end