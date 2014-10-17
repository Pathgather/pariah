require 'spec_helper'

describe Fracas, '.connect' do
  it "should instantiate a Fracas::Cluster instance" do
    Fracas.connect.should be_an_instance_of Fracas::Cluster
  end
end
