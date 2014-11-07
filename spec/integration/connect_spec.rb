require 'spec_helper'

describe Fracas, '.connect' do
  it "should instantiate a Fracas::Dataset instance" do
    ds = Fracas.connect
    ds.should be_an_instance_of Fracas::Dataset
    proc { ds.client.info }.should_not raise_error
  end

  it "should accept an already existing Elasticsearch::Transport::Client instance" do
    client = Elasticsearch::Client.new
    ds = Fracas.connect(client)
    ds.should be_an_instance_of Fracas::Dataset
    proc { ds.client.info }.should_not raise_error
  end
end
