require 'spec_helper'

describe "Cluster.pca" do
  it "performs principal component analysis where nrows > ncols" do
    data = [
      [ 3.1, 1.2 ],
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
      [ 5.1, 5.2 ],
    ]

    mean, coordinates, pc, eigenvalues = Cluster.pca(data)

    mean[0].should be_within(0.001).of(3.5461538461538464)
    mean[1].should be_within(0.001).of(3.5307692307692311)
    coordinates[0][0].should be_within(0.001).of(2.0323189722653883)
    coordinates[0][1].should be_within(0.001).of(1.2252420399694917)
    coordinates[1][0].should be_within(0.001).of(3.0936985166252251)
    coordinates[1][1].should be_within(0.001).of(-0.10647619705157851)
    coordinates[2][0].should be_within(0.001).of(3.1453186907749426)
    coordinates[2][1].should be_within(0.001).of(-0.46331699855941139)
    coordinates[3][0].should be_within(0.001).of(2.5440202962223761)
    coordinates[3][1].should be_within(0.001).of(0.20633980959571077)
    coordinates[4][0].should be_within(0.001).of(2.4468278463376221)
    coordinates[4][1].should be_within(0.001).of(-0.28412285736824866)
    coordinates[5][0].should be_within(0.001).of(2.4468278463376221)
    coordinates[5][1].should be_within(0.001).of(-0.28412285736824866)
    coordinates[6][0].should be_within(0.001).of(-3.2018619434743254)
    coordinates[6][1].should be_within(0.001).of(0.019692314198662915)
    coordinates[7][0].should be_within(0.001).of(-3.2018619434743254)
    coordinates[7][1].should be_within(0.001).of(0.019692314198662915)
    coordinates[8][0].should be_within(0.001).of(0.46978641990344067)
    coordinates[8][1].should be_within(0.001).of(-0.17778754731982949)
    coordinates[9][0].should be_within(0.001).of(-2.5549912731867215)
    coordinates[9][1].should be_within(0.001).of(0.19733897451533403)
    coordinates[10][0].should be_within(0.001).of(-2.5033710990370044)
    coordinates[10][1].should be_within(0.001).of(-0.15950182699250004)
    coordinates[11][0].should be_within(0.001).of(-2.4365601663089413)
    coordinates[11][1].should be_within(0.001).of(-0.23390813900973562)
    coordinates[12][0].should be_within(0.001).of(-2.2801521629852974)
    coordinates[12][1].should be_within(0.001).of(  0.0409309711916888)
    pc[0][0].should be_within(0.001).of(-0.66810932728062988)
    pc[0][1].should be_within(0.001).of(-0.74406312017235743)
    pc[1][0].should be_within(0.001).of(  0.74406312017235743)
    pc[1][1].should be_within(0.001).of(-0.66810932728062988)
    eigenvalues[0].should be_within(0.001).of( 9.3110471246032844)
    eigenvalues[1].should be_within(0.001).of( 1.4437456297481428)
  end

  it "performs principal component analysis where ncols > nrows" do
    data = [[ 2.3, 4.5, 1.2, 6.7, 5.3, 7.1],
            [ 1.3, 6.5, 2.2, 5.7, 6.2, 9.1],
            [ 3.2, 7.2, 3.2, 7.4, 7.3, 8.9],
            [ 4.2, 5.2, 9.2, 4.4, 6.3, 7.2]]

    mean, coordinates, pc, eigenvalues = Cluster.pca(data)

    mean[0].should be_within(0.001).of( 2.7500)
    mean[1].should be_within(0.001).of( 5.8500)
    mean[2].should be_within(0.001).of( 3.9500)
    mean[3].should be_within(0.001).of( 6.0500)
    mean[4].should be_within(0.001).of( 6.2750)
    mean[5].should be_within(0.001).of( 8.0750)
    coordinates[0][0].should be_within(0.001).of(2.6460846688406905)
    coordinates[0][1].should be_within(0.001).of(-2.1421701432732418)
    coordinates[0][2].should be_within(0.001).of(-0.56620932754145858)
    coordinates[0][3].should be_within(0.001).of(0.0)
    coordinates[1][0].should be_within(0.001).of(2.0644120899917544)
    coordinates[1][1].should be_within(0.001).of(0.55542108669180323)
    coordinates[1][2].should be_within(0.001).of(1.4818772348457117)
    coordinates[1][3].should be_within(0.001).of(0.0)
    coordinates[2][0].should be_within(0.001).of(1.0686641862092987)
    coordinates[2][1].should be_within(0.001).of(1.9994412069101073)
    coordinates[2][2].should be_within(0.001).of(-1.000720598980291)
    coordinates[2][3].should be_within(0.001).of(0.0)
    coordinates[3][0].should be_within(0.001).of(-5.77916094504174)
    coordinates[3][1].should be_within(0.001).of(-0.41269215032867046)
    coordinates[3][2].should be_within(0.001).of(0.085052691676038017)
    coordinates[3][3].should be_within(0.001).of(0.0)
    pc[0][0].should be_within(0.001).of(-0.26379660005997291)
    pc[0][1].should be_within(0.001).of(  0.064814972617134495)
    pc[0][2].should be_within(0.001).of(-0.91763310094893846)
    pc[0][3].should be_within(0.001).of(  0.26145408875373249)
    pc[1][0].should be_within(0.001).of(  0.05073770520434398)
    pc[1][1].should be_within(0.001).of(  0.68616983388698793)
    pc[1][2].should be_within(0.001).of(  0.13819106187213354)
    pc[1][3].should be_within(0.001).of(  0.19782544121828985)
    pc[2][0].should be_within(0.001).of(-0.63000893660095947)
    pc[2][1].should be_within(0.001).of(  0.091155993862151397)
    pc[2][2].should be_within(0.001).of(  0.045630391256086845)
    pc[2][3].should be_within(0.001).of(-0.67456694780914772)

    # As the last eigenvalue is zero, the corresponding eigenvector is
    # strongly affected by roundoff error, and is not being tested here.
    # For PCA, this doesn't matter since all data have a zero coefficient
    # along this eigenvector.

    eigenvalues[0].should be_within(0.001).of( 6.7678878332578778)
    eigenvalues[1].should be_within(0.001).of( 3.0108911400291856)
    eigenvalues[2].should be_within(0.001).of( 1.8775592718563467)
    eigenvalues[3].should be_within(0.001).of( 0.0)
  end
end

