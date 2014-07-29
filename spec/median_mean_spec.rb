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
    Cluster.median(data[0]).should == 3.0
    Cluster.median(data[1]).should == 12.5
    Cluster.median(data[2]).should == 6.0
    Cluster.median(data[3]).should == 1.45
  end

  it "calculates the mean" do
    Cluster.mean(data[0]).should be_within(0.001).of(13.1)
    Cluster.mean(data[1]).should be_within(0.001).of(12.5)
    Cluster.mean(data[2]).should be_within(0.001).of(7.375)
    Cluster.mean(data[3]).should be_within(0.001).of(15.988)
  end
end