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

      tree.size.should == data.size - 1

      tree[0].left.should == 2
      tree[0].right.should == 1
      tree[0].distance.should be_within(0.001).of(2.600)

      tree[1].left.should == -1
      tree[1].right.should == 0
      tree[1].distance.should be_within(0.001).of(7.300)

      tree[2].left.should == 3
      tree[2].right.should == -2
      tree[2].distance.should be_within(0.001).of(21.348)
    end

    it "calcultes pairwise single-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 's',
                                       :dist      => 'e'

      tree.size.should == data.size - 1

      tree[0].left.should == 1
      tree[0].right.should == 2
      tree[0].distance.should be_within(0.001).of(2.600)

      tree[1].left.should == 0
      tree[1].right.should == -1
      tree[1].distance.should be_within(0.001).of(5.800)

      tree[2].left.should == -2
      tree[2].right.should == 3
      tree[2].distance.should be_within(0.001).of(12.908)
    end

    it "calculates pairwise centroid-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'c',
                                       :dist      => 'e'

     tree.size.should == data.size - 1

      tree[0].left.should == 1
      tree[0].right.should == 2
      tree[0].distance.should be_within(0.001).of(2.600)
      tree[1].left.should == 0
      tree[1].right.should == -1
      tree[1].distance.should be_within(0.001).of(6.650)
      tree[2].left.should == -2
      tree[2].right.should == 3
      tree[2].distance.should be_within(0.001).of(19.437)
    end

    it "calculates pairwise maximum-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'm',
                                       :dist      => 'e'

      tree.size.should == data.size - 1

      tree[0].left.should == 2
      tree[0].right.should == 1
      tree[0].distance.should be_within(0.001).of(2.600)
      tree[1].left.should == -1
      tree[1].right.should == 0
      tree[1].distance.should be_within(0.001).of(8.800)
      tree[2].left.should == 3
      tree[2].right.should == -2
      tree[2].distance.should be_within(0.001).of(32.508)
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

      tree.size.should == data.size - 1
      tree[0].left.should == 5
      tree[0].right.should == 4
      tree[0].distance.should be_within(0.001).of(0.003)

      tree[1].left.should == 9
      tree[1].right.should == 12
      tree[1].distance.should be_within(0.001).of(0.029)

      tree[2].left.should == 2
      tree[2].right.should == 1
      tree[2].distance.should be_within(0.001).of(0.061)

      tree[3].left.should == 11
      tree[3].right.should == -2
      tree[3].distance.should be_within(0.001).of(0.070)

      tree[4].left.should == -4
      tree[4].right.should == 10
      tree[4].distance.should be_within(0.001).of(0.128)

      tree[5].left.should == 7
      tree[5].right.should == -5
      tree[5].distance.should be_within(0.001).of(0.224)

      tree[6].left.should == -3
      tree[6].right.should == 0
      tree[6].distance.should be_within(0.001).of(0.254)

      tree[7].left.should == -1
      tree[7].right.should == 3
      tree[7].distance.should be_within(0.001).of(0.391)

      tree[8].left.should == -8
      tree[8].right.should == -7
      tree[8].distance.should be_within(0.001).of(0.532)

      tree[9].left.should == 8
      tree[9].right.should == -9
      tree[9].distance.should be_within(0.001).of(3.234)

      tree[10].left.should == -6
      tree[10].right.should == 6
      tree[10].distance.should be_within(0.001).of(4.636)

      tree[11].left.should == -11
      tree[11].right.should == -10
      tree[11].distance.should be_within(0.001).of(12.741)
    end

    it "calculates pairwise single-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 's',
                                       :dist      => 'e'

      tree.size.should == data.size - 1

      tree[0].left.should == 4
      tree[0].right.should == 5
      tree[0].distance.should be_within(0.001).of(0.003)

      tree[1].left.should == 9
      tree[1].right.should == 12
      tree[1].distance.should be_within(0.001).of(0.029)

      tree[2].left.should == 11
      tree[2].right.should == -2
      tree[2].distance.should be_within(0.001).of(0.033)

      tree[3].left.should == 1
      tree[3].right.should == 2
      tree[3].distance.should be_within(0.001).of(0.061)

      tree[4].left.should == 10
      tree[4].right.should == -3
      tree[4].distance.should be_within(0.001).of(0.077)

      tree[5].left.should == 7
      tree[5].right.should == -5
      tree[5].distance.should be_within(0.001).of(0.092)

      tree[6].left.should == 0
      tree[6].right.should == -4
      tree[6].distance.should be_within(0.001).of(0.242)

      tree[7].left.should == -7
      tree[7].right.should == -1
      tree[7].distance.should be_within(0.001).of(0.246)

      tree[8].left.should == 3
      tree[8].right.should == -8
      tree[8].distance.should be_within(0.001).of(0.287)

      tree[9].left.should == -9
      tree[9].right.should == 8
      tree[9].distance.should be_within(0.001).of(1.936)

      tree[10].left.should == -10
      tree[10].right.should == -6
      tree[10].distance.should be_within(0.001).of(3.432)

      tree[11].left.should == 6
      tree[11].right.should == -11
      tree[11].distance.should be_within(0.001).of(3.535)
    end

    it "calculates pairwise centroid-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'c',
                                       :dist      => 'e'

      tree.size.should == data.size - 1

      tree[0].left.should == 4
      tree[0].right.should == 5
      tree[0].distance.should be_within(0.001).of(0.003)

      tree[1].left.should == 12
      tree[1].right.should == 9
      tree[1].distance.should be_within(0.001).of(0.029)

      tree[2].left.should == 1
      tree[2].right.should == 2
      tree[2].distance.should be_within(0.001).of(0.061)

      tree[3].left.should == -2
      tree[3].right.should == 11
      tree[3].distance.should be_within(0.001).of(0.063)

      tree[4].left.should == 10
      tree[4].right.should == -4
      tree[4].distance.should be_within(0.001).of(0.109)

      tree[5].left.should == -5
      tree[5].right.should == 7
      tree[5].distance.should be_within(0.001).of(0.189)

      tree[6].left.should == 0
      tree[6].right.should == -3
      tree[6].distance.should be_within(0.001).of(0.239)

      tree[7].left.should == 3
      tree[7].right.should == -1
      tree[7].distance.should be_within(0.001).of(0.390)

      tree[8].left.should == -7
      tree[8].right.should == -8
      tree[8].distance.should be_within(0.001).of(0.382)

      tree[9].left.should == -9
      tree[9].right.should == 8
      tree[9].distance.should be_within(0.001).of(3.063)

      tree[10].left.should == 6
      tree[10].right.should == -6
      tree[10].distance.should be_within(0.001).of(4.578)

      tree[11].left.should == -10
      tree[11].right.should == -11
      tree[11].distance.should be_within(0.001).of(11.536)
    end

    it "calculates pairwise maximum-linkage clustering" do
      tree = Cluster.treecluster data, :mask      => mask,
                                       :weight    => weight,
                                       :transpose => false,
                                       :method    => 'm',
                                       :dist      => 'e'

      tree.size.should == data.size - 1

      tree[0].left.should == 5
      tree[0].right.should == 4
      tree[0].distance.should be_within(0.001).of(0.003)

      tree[1].left.should == 9
      tree[1].right.should == 12
      tree[1].distance.should be_within(0.001).of(0.029)

      tree[2].left.should == 2
      tree[2].right.should == 1
      tree[2].distance.should be_within(0.001).of(0.061)

      tree[3].left.should == 11
      tree[3].right.should == 10
      tree[3].distance.should be_within(0.001).of(0.077)

      tree[4].left.should == -2
      tree[4].right.should == -4
      tree[4].distance.should be_within(0.001).of(0.216)

      tree[5].left.should == -3
      tree[5].right.should == 0
      tree[5].distance.should be_within(0.001).of(0.266)

      tree[6].left.should == -5
      tree[6].right.should == 7
      tree[6].distance.should be_within(0.001).of(0.302)

      tree[7].left.should == -1
      tree[7].right.should == 3
      tree[7].distance.should be_within(0.001).of(0.425)

      tree[8].left.should == -8
      tree[8].right.should == -6
      tree[8].distance.should be_within(0.001).of(0.968)

      tree[9].left.should == 8
      tree[9].right.should == 6
      tree[9].distance.should be_within(0.001).of(3.975)

      tree[10].left.should == -10
      tree[10].right.should == -7
      tree[10].distance.should be_within(0.001).of(5.755)

      tree[11].left.should == -11
      tree[11].right.should == -9
      tree[11].distance.should be_within(0.001).of(22.734)
    end

  end
end

