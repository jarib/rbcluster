module Cluster
  class Tree
    def initialize(nodes)
      @nodes = Array(nodes)
      @nodes.each_with_index do |node, idx|
        unless node.kind_of?(Node)
          raise ArgumentError, "expected #{Node.class}, got #{node.class} at index #{idx}"
        end
      end

    end

    def size
      @nodes.size
    end

    def to_a
      @nodes.dup
    end

    def to_s
      @nodes.map { |e| "#{e}\n" }.join
    end

    def [](idx)
      @nodes[idx]
    end

    def fetch(idx, &blk)
      @nodes.fetch(idx, &blk)
    end

    def scale
      max = @nodes.map { |e| e.distance }.max
      @nodes.each do |node|
        node.distance = node.distance /= max
      end

      nil
    end

    def cut(nclusters)
      Cluster.cuttree(@nodes, nclusters)
    end

  end
end
