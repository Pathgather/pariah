require 'spec_helper'

describe Fracas, '.connect' do
  it "should instantiate a Fracas::Dataset instance" do
    Fracas.connect.should be_an_instance_of Fracas::Dataset
  end
end
