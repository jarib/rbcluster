require 'spec_helper'

describe "Cluster.somcluster" do

  it "calculates somcluster for a first data set" do
    weight = [ 1,1,1,1,1 ]
    data = [
      [  1.1, 2.2, 3.3, 4.4, 5.5],
      [  3.1, 3.2, 1.3, 2.4, 1.5],
      [  4.1, 2.2, 0.3, 5.4, 0.5],
      [ 12.1, 2.0, 0.0, 5.0, 0.0]
    
    ]
    mask = [
      [ 1, 1, 1, 1, 1],
      [ 1, 1, 1, 1, 1],
      [ 1, 1, 1, 1, 1],
      [ 1, 1, 1, 1, 1]
    ]

    clusterid, celldata = Cluster.somcluster data, :mask      => mask, 
                                                   :weight    => weight,
                                                   :transpose => false,
                                                   :nxgrid    => 10,
                                                   :nygrid    => 10,
                                                   :inittau   => 0.02,
                                                   :niter     => 100,
                                                   :dist      => 'e'
                                                   
   clusterid.size.should == data.size
   clusterid[0].should == 2
  end

  it "calculates somcluster for a second data set" do
      weight =  [ 1,1 ]
      data = [
        [ 1.1, 1.2 ],
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
        [ 5.1, 5.2 ]
      ]

      mask = [
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

      clusterid, celldata = Cluster.somcluster data, :mask      => mask,
                                                     :weight    => weight,
                                                     :transpose => false,
                                                     :nxgrid    => 10,
                                                     :nygrid    => 10,
                                                     :inittau   => 0.02,
                                                     :niter     => 100,
                                                     :dist      => 'e'

      clusterid.size.should == data.size
      clusterid[0].should == 2
  end
end