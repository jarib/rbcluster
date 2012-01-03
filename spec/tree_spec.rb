require 'spec_helper'

module Cluster
  describe Tree do
    context "creating" do
      it "should raise ArgumentError if not given an array of Nodes" do
        lambda { Tree.new(1) }.should raise_error(ArgumentError)
        lambda { Tree.new([Node.new(1,2), Node.new(2,3), nil]) }.should raise_error(ArgumentError)
      end

      it "returns a Tree instance when given an array of nodes" do
        Tree.new([Node.new(1, 2)]).should be_kind_of(Tree)
      end
    end

    context "using" do
      let :tree do
        Tree.new(Cluster.treecluster([
            [  1.1, 2.2, 3.3, 4.4, 5.5],
            [  3.1, 3.2, 1.3, 2.4, 1.5],
            [  4.1, 2.2, 0.3, 5.4, 0.5],
            [ 12.1, 2.0, 0.0, 5.0, 0.0]
          ])
        )
      end

      it "fetches a copy of the node array" do
        arr = tree.to_a
        arr.should be_kind_of(Array)
        arr.size.should == 3
        arr.clear

        tree.size.should == 3
      end

      it "has a string representation" do
        tree.to_s.should include('(2, 1): 2.6')
      end

      it "can scale the tree" do
        tree.scale
        tree.to_a.each { |n| n.distance.should be_between(0, 1)  }
      end

      it "can cut the tree" do
        tree.cut(3).should == [1, 2, 2, 0]
      end
    end
  end
end