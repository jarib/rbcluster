require 'spec_helper'

describe "Cluster.clusterdistance" do
  it "calculates distances for data set 1" do
    weight = [ 1,1,1,1,1 ]
    data   = [[  1.1, 2.2, 3.3, 4.4, 5.5, ],
              [  3.1, 3.2, 1.3, 2.4, 1.5, ],
              [  4.1, 2.2, 0.3, 5.4, 0.5, ],
              [ 12.1, 2.0, 0.0, 5.0, 0.0, ]]

    mask   = [[ 1, 1, 1, 1, 1],
              [ 1, 1, 1, 1, 1],
              [ 1, 1, 1, 1, 1],
              [ 1, 1, 1, 1, 1]]

    # Cluster assignments
    c1 = [0]
    c2 = [1,2]
    c3 = [3]

    distance = Cluster.clusterdistance data, c1, c2, :mask      => mask,
                                                     :weight    => weight,
                                                     :dist      => 'e',
                                                     :method    => 'a',
                                                     :transpose => false

    distance.should be_within(0.001).of(6.650)

    distance = Cluster.clusterdistance data, c1, c3, :mask      => mask,
                                                     :weight    => weight,
                                                     :dist      => 'e',
                                                     :method    => 'a',
                                                     :transpose => false

    distance.should be_within(0.001).of(32.508)

    distance = Cluster.clusterdistance data, c2, c3, :mask      => mask,
                                                     :weight    => weight,
                                                     :dist      => 'e',
                                                     :method    => 'a',
                                                     :transpose => false

    distance.should be_within(0.001).of(15.118)
  end

  it "calculates distances for data set 2" do
    weight =  [ 1,1 ]
    data   =  [[ 1.1, 1.2 ],
               [ 1.4, 1.3 ],
               [ 1.1, 1.5 ],
               [ 2.0, 1.5 ],
               [ 1.7, 1.9 ],
               [ 1.7, 1.9 ],
               [ 5.7, 5.9 ],
               [ 5.7, 5.9 ],
               [ 3.1, 3.3 ],
               [ 5.4, 5.3 ],
               [ 5.1, 5.5 ],
               [ 5.0, 5.5 ],
               [ 5.1, 5.2 ]]
    mask = [[ 1, 1 ],
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
            [ 1, 1 ]]

    # Cluster assignments
    c1 = [ 0, 1, 2, 3 ]
    c2 = [ 4, 5, 6, 7 ]
    c3 = [ 8 ]

    distance = Cluster.clusterdistance data, c1, c2, :mask      => mask,
                                                     :weight    => weight,
                                                     :dist      => 'e',
                                                     :method    => 'a',
                                                     :transpose => false

    distance.should be_within(0.001).of(5.833)

    distance = Cluster.clusterdistance data, c1, c3, :mask      => mask,
                                                     :weight    => weight,
                                                     :dist      => 'e',
                                                     :method    => 'a',
                                                     :transpose => false

    distance.should be_within(0.001).of(3.298)


    distance = Cluster.clusterdistance data, c2, c3, :mask      => mask,
                                                     :weight    => weight,
                                                     :dist      => 'e',
                                                     :method    => 'a',
                                                     :transpose => false

    distance.should be_within(0.001).of(0.360)
  end
end

