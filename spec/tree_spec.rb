require 'spec_helper'

module Cluster
  describe Tree do
    context "creating" do
      it "raises ArgumentError if not given an array of Nodes" do
        expect { Tree.new(1) }.to raise_error(ArgumentError)
        expect { Tree.new([Node.new(1,2), Node.new(2,3), nil]) }.to raise_error(ArgumentError)
        expect { Tree.new }.to raise_error(ArgumentError)
      end

      it "returns a Tree instance when given an array of nodes" do
        expect(Tree.new([Node.new(1, 2)])).to be_kind_of(Tree)
      end
    end

    context "using" do
      let :tree do
        Cluster.treecluster([
            [  1.1, 2.2, 3.3, 4.4, 5.5],
            [  3.1, 3.2, 1.3, 2.4, 1.5],
            [  4.1, 2.2, 0.3, 5.4, 0.5],
            [ 12.1, 2.0, 0.0, 5.0, 0.0]
        ])
      end

      it "fetches a copy of the node array" do
        arr = tree.to_a
        expect(arr).to be_kind_of(Array)
        expect(arr.size).to eq(3)
        arr.clear

        expect(tree.size).to eq(3)
      end

      it "has a string representation" do
        expect(tree.to_s).to include('(2, 1): 2.6')
      end

      it "can scale the tree" do
        tree.scale
        tree.to_a.each { |n| expect(n.distance).to be_between(0, 1)  }
      end

      it "can cut the tree" do
        expect(tree.cut(3)).to eq([1, 2, 2, 0])
      end

      it "gets a node" do
        expect(tree[0]).to eq(tree.to_a[0])
      end

      it "fetches a node" do
        expect(tree.fetch(0)).to eq(tree.to_a[0])
      end
    end
  end
end