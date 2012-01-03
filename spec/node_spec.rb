require 'spec_helper'

module Cluster
  describe Node do
    it "creates a new node with left/right" do
      n = Node.new(2, 3)
      n.left.should == 2
      n.right.should == 3
      n.distance.should == 0.0
    end

    it "takes an optional distance" do
      n = Node.new(2, 3, 0.91)

      n.left.should == 2
      n.right.should == 3
      n.distance.should == 0.91
    end

    it "is mutable" do
      n = Node.new(2, 3, 0.91)

      n.left = 4
      n.right = 5
      n.distance = 2.1
    end
  end
end
