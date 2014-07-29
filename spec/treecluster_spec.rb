require 'spec_helper'

describe "Cluster.treecluster" do
  context "first data set" do
    let(:weight) { [ 1,1,1,1,1 ] }
    let(:data) {
      [
        [  1.1, 2.2, 3.3, 4.4, 5.5],
        [  3.1, 3.2, 1.3, 2.4, 1.5],
        [  4.1, 2.2, 0.3, 5.4, 0.5],
        [ 12.1, 2.0, 0.0, 5.0, 0.0]
      ]
    }

    let(:mask) {
      [
        [ 1, 1, 1, 1, 1],
        [ 1, 1, 1, 1, 1],
        [ 1, 1, 1, 1, 1],
        [ 1, 1, 1, 1, 1]
      ]
    }

    it "calculates pairwise average-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'a',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(2)
      expect(tree[0].right).to be(1)
      expect(tree[0].distance).to be_within(0.001).of(2.600)

      expect(tree[1].left).to be(-1)
      expect(tree[1].right).to be(0)
      expect(tree[1].distance).to be_within(0.001).of(7.300)

      expect(tree[2].left).to be(3)
      expect(tree[2].right).to be(-2)
      expect(tree[2].distance).to be_within(0.001).of(21.348)
    end

    it "calcultes pairwise single-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 's',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(1)
      expect(tree[0].right).to be(2)
      expect(tree[0].distance).to be_within(0.001).of(2.600)

      expect(tree[1].left).to be(0)
      expect(tree[1].right).to be(-1)
      expect(tree[1].distance).to be_within(0.001).of(5.800)

      expect(tree[2].left).to be(-2)
      expect(tree[2].right).to be(3)
      expect(tree[2].distance).to be_within(0.001).of(12.908)
    end

    it "calculates pairwise centroid-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'c',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(1)
      expect(tree[0].right).to be(2)
      expect(tree[0].distance).to be_within(0.001).of(2.600)
      expect(tree[1].left).to be(0)
      expect(tree[1].right).to be(-1)
      expect(tree[1].distance).to be_within(0.001).of(6.650)
      expect(tree[2].left).to be(-2)
      expect(tree[2].right).to be(3)
      expect(tree[2].distance).to be_within(0.001).of(19.437)
    end

    it "calculates pairwise maximum-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'm',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(2)
      expect(tree[0].right).to be(1)
      expect(tree[0].distance).to be_within(0.001).of(2.600)
      expect(tree[1].left).to be(-1)
      expect(tree[1].right).to be(0)
      expect(tree[1].distance).to be_within(0.001).of(8.800)
      expect(tree[2].left).to be(3)
      expect(tree[2].right).to be(-2)
      expect(tree[2].distance).to be_within(0.001).of(32.508)
    end
  end

  context "second data set" do
    let(:weight) { [ 1,1 ] }
    let(:data) {
       [
         [ 0.8223, 0.9295 ],
         [ 1.4365, 1.3223 ],
         [ 1.1623, 1.5364 ],
         [ 2.1826, 1.1934 ],
         [ 1.7763, 1.9352 ],
         [ 1.7215, 1.9912 ],
         [ 2.1812, 5.9935 ],
         [ 5.3290, 5.9452 ],
         [ 3.1491, 3.3454 ],
         [ 5.1923, 5.3156 ],
         [ 4.7735, 5.4012 ],
         [ 5.1297, 5.5645 ],
         [ 5.3934, 5.1823 ]
       ]
    }

    let(:mask) {
      [
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ],
        [ 1, 1 ]
      ]
    }

    it "calculates pairwise average-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'a',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)
      expect(tree[0].left).to be(5)
      expect(tree[0].right).to be(4)
      expect(tree[0].distance).to be_within(0.001).of(0.003)

      expect(tree[1].left).to be(9)
      expect(tree[1].right).to be(12)
      expect(tree[1].distance).to be_within(0.001).of(0.029)

      expect(tree[2].left).to be(2)
      expect(tree[2].right).to be(1)
      expect(tree[2].distance).to be_within(0.001).of(0.061)

      expect(tree[3].left).to be(11)
      expect(tree[3].right).to be(-2)
      expect(tree[3].distance).to be_within(0.001).of(0.070)

      expect(tree[4].left).to be(-4)
      expect(tree[4].right).to be(10)
      expect(tree[4].distance).to be_within(0.001).of(0.128)

      expect(tree[5].left).to be(7)
      expect(tree[5].right).to be(-5)
      expect(tree[5].distance).to be_within(0.001).of(0.224)

      expect(tree[6].left).to be(-3)
      expect(tree[6].right).to be(0)
      expect(tree[6].distance).to be_within(0.001).of(0.254)

      expect(tree[7].left).to be(-1)
      expect(tree[7].right).to be(3)
      expect(tree[7].distance).to be_within(0.001).of(0.391)

      expect(tree[8].left).to be(-8)
      expect(tree[8].right).to be(-7)
      expect(tree[8].distance).to be_within(0.001).of(0.532)

      expect(tree[9].left).to be(8)
      expect(tree[9].right).to be(-9)
      expect(tree[9].distance).to be_within(0.001).of(3.234)

      expect(tree[10].left).to be(-6)
      expect(tree[10].right).to be(6)
      expect(tree[10].distance).to be_within(0.001).of(4.636)

      expect(tree[11].left).to be(-11)
      expect(tree[11].right).to be(-10)
      expect(tree[11].distance).to be_within(0.001).of(12.741)
    end

    it "calculates pairwise single-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 's',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(4)
      expect(tree[0].right).to be(5)
      expect(tree[0].distance).to be_within(0.001).of(0.003)

      expect(tree[1].left).to be(9)
      expect(tree[1].right).to be(12)
      expect(tree[1].distance).to be_within(0.001).of(0.029)

      expect(tree[2].left).to be(11)
      expect(tree[2].right).to be(-2)
      expect(tree[2].distance).to be_within(0.001).of(0.033)

      expect(tree[3].left).to be(1)
      expect(tree[3].right).to be(2)
      expect(tree[3].distance).to be_within(0.001).of(0.061)

      expect(tree[4].left).to be(10)
      expect(tree[4].right).to be(-3)
      expect(tree[4].distance).to be_within(0.001).of(0.077)

      expect(tree[5].left).to be(7)
      expect(tree[5].right).to be(-5)
      expect(tree[5].distance).to be_within(0.001).of(0.092)

      expect(tree[6].left).to be(0)
      expect(tree[6].right).to be(-4)
      expect(tree[6].distance).to be_within(0.001).of(0.242)

      expect(tree[7].left).to be(-7)
      expect(tree[7].right).to be(-1)
      expect(tree[7].distance).to be_within(0.001).of(0.246)

      expect(tree[8].left).to be(3)
      expect(tree[8].right).to be(-8)
      expect(tree[8].distance).to be_within(0.001).of(0.287)

      expect(tree[9].left).to be(-9)
      expect(tree[9].right).to be(8)
      expect(tree[9].distance).to be_within(0.001).of(1.936)

      expect(tree[10].left).to be(-10)
      expect(tree[10].right).to be(-6)
      expect(tree[10].distance).to be_within(0.001).of(3.432)

      expect(tree[11].left).to be(6)
      expect(tree[11].right).to be(-11)
      expect(tree[11].distance).to be_within(0.001).of(3.535)
    end

    it "calculates pairwise centroid-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'c',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(4)
      expect(tree[0].right).to be(5)
      expect(tree[0].distance).to be_within(0.001).of(0.003)

      expect(tree[1].left).to be(12)
      expect(tree[1].right).to be(9)
      expect(tree[1].distance).to be_within(0.001).of(0.029)

      expect(tree[2].left).to be(1)
      expect(tree[2].right).to be(2)
      expect(tree[2].distance).to be_within(0.001).of(0.061)

      expect(tree[3].left).to be(-2)
      expect(tree[3].right).to be(11)
      expect(tree[3].distance).to be_within(0.001).of(0.063)

      expect(tree[4].left).to be(10)
      expect(tree[4].right).to be(-4)
      expect(tree[4].distance).to be_within(0.001).of(0.109)

      expect(tree[5].left).to be(-5)
      expect(tree[5].right).to be(7)
      expect(tree[5].distance).to be_within(0.001).of(0.189)

      expect(tree[6].left).to be(0)
      expect(tree[6].right).to be(-3)
      expect(tree[6].distance).to be_within(0.001).of(0.239)

      expect(tree[7].left).to be(3)
      expect(tree[7].right).to be(-1)
      expect(tree[7].distance).to be_within(0.001).of(0.390)

      expect(tree[8].left).to be(-7)
      expect(tree[8].right).to be(-8)
      expect(tree[8].distance).to be_within(0.001).of(0.382)

      expect(tree[9].left).to be(-9)
      expect(tree[9].right).to be(8)
      expect(tree[9].distance).to be_within(0.001).of(3.063)

      expect(tree[10].left).to be(6)
      expect(tree[10].right).to be(-6)
      expect(tree[10].distance).to be_within(0.001).of(4.578)

      expect(tree[11].left).to be(-10)
      expect(tree[11].right).to be(-11)
      expect(tree[11].distance).to be_within(0.001).of(11.536)
    end

    it "calculates pairwise maximum-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'm',
                                       :dist      => 'e'

      expect(tree.size).to be(data.size - 1)

      expect(tree[0].left).to be(5)
      expect(tree[0].right).to be(4)
      expect(tree[0].distance).to be_within(0.001).of(0.003)

      expect(tree[1].left).to be(9)
      expect(tree[1].right).to be(12)
      expect(tree[1].distance).to be_within(0.001).of(0.029)

      expect(tree[2].left).to be(2)
      expect(tree[2].right).to be(1)
      expect(tree[2].distance).to be_within(0.001).of(0.061)

      expect(tree[3].left).to be(11)
      expect(tree[3].right).to be(10)
      expect(tree[3].distance).to be_within(0.001).of(0.077)

      expect(tree[4].left).to be(-2)
      expect(tree[4].right).to be(-4)
      expect(tree[4].distance).to be_within(0.001).of(0.216)

      expect(tree[5].left).to be(-3)
      expect(tree[5].right).to be(0)
      expect(tree[5].distance).to be_within(0.001).of(0.266)

      expect(tree[6].left).to be(-5)
      expect(tree[6].right).to be(7)
      expect(tree[6].distance).to be_within(0.001).of(0.302)

      expect(tree[7].left).to be(-1)
      expect(tree[7].right).to be(3)
      expect(tree[7].distance).to be_within(0.001).of(0.425)

      expect(tree[8].left).to be(-8)
      expect(tree[8].right).to be(-6)
      expect(tree[8].distance).to be_within(0.001).of(0.968)

      expect(tree[9].left).to be(8)
      expect(tree[9].right).to be(6)
      expect(tree[9].distance).to be_within(0.001).of(3.975)

      expect(tree[10].left).to be(-10)
      expect(tree[10].right).to be(-7)
      expect(tree[10].distance).to be_within(0.001).of(5.755)

      expect(tree[11].left).to be(-11)
      expect(tree[11].right).to be(-9)
      expect(tree[11].distance).to be_within(0.001).of(22.734)
    end
  end

  context "bad input" do
    it "fails for a ragged matrix" do
      ragged = [
          [ 91.1, 92.2, 93.3, 94.4, 95.5],
          [ 93.1, 93.2, 91.3, 92.4 ],
          [ 94.1, 92.2, 90.3 ],
          [ 12.1, 92.0, 90.0, 95.0, 90.0 ]
        ]

      expect { Cluster.treecluster(ragged) }.to raise_error(ArgumentError)
    end

    it "fails for a matrix with bad cells" do
      bad_cells = [
        [ 7.1, 7.2, 7.3, 7.4, 7.5, ],
        [ 7.1, 7.2, 7.3, 7.4, 'snoopy'],
        [ 7.1, 7.2, 7.3, nil, nil]
      ]

      expect { Cluster.treecluster(bad_cells) }.to raise_error(TypeError)
    end

    it "fails for a matrix with a bad row" do
      bad_row = [
        [ 23.1, 23.2, 23.3, 23.4, 23.5],
        nil,
        [ 23.1, 23.0, 23.0, 23.0, 23.0]
      ]

      expect { Cluster.treecluster(bad_row) }.to raise_error(TypeError)
    end
  end
end

