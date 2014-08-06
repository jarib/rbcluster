require 'spec_helper'

module Cluster
  describe Node do
    it "creates a new node with left/right" do
      n = Node.new(2, 3)
      expect(n.left).to eq(2)
      expect(n.right).to eq(3)
      expect(n.distance).to eq(0.0)
    end

    it "takes an optional distance" do
      n = Node.new(2, 3, 0.91)

      expect(n.left).to eq(2)
      expect(n.right).to eq(3)
      expect(n.distance).to eq(0.91)
    end

    it "is mutable" do
      n = Node.new(2, 3, 0.91)

      n.left = 4
      n.right = 5
      n.distance = 2.1
    end
  end
end
