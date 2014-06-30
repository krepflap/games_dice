require 'helpers'

describe GamesDice::DieDescription do

  describe ".new" do

    it "should accept a single parameter: sides" do
      dd = GamesDice::DieDescription.new( 6 )
      expect( dd ).to be_a GamesDice::DieDescription
      expect( dd.sides ).to eql 6
      expect( dd.label ).to eql 'd6'
    end

    it "should accept two params: sides, label" do
      dd = GamesDice::DieDescription.new( 8, 'brutal-d8' )
      expect( dd ).to be_a GamesDice::DieDescription
      expect( dd.sides ).to eql 8
      expect( dd.label ).to eql 'brutal-d8'
    end

  end

end
