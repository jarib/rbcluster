module Cluster
  class Node
    def to_s
      "(#{@left}, #{@right}): #{@distance}"
    end
  end
end