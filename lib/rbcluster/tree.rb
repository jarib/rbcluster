module Cluster
  class Tree
    def initialize(nodes)
      raise NotImplementedError, "patches welcome :)"

      nodes.each_with_index do |node, idx|
        unless node.kind_of?(Node)
          raise ArgumentError, "expected #{Node.class}, got #{node.class} at index #{idx}"
        end
      end

      @nodes = nodes
    end

    def size
      @nodes.size
    end

  end
end
