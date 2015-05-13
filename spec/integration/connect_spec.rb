require 'spec_helper'

describe Pariah, '.connect' do
  it "should instantiate a Pariah::Dataset instance" do
    ds = Pariah.connect
    ds.should be_an_instance_of Pariah::Dataset
    proc { ds.client.info }.should_not raise_error
  end

  it "should accept an already existing Elasticsearch::Transport::Client instance" do
    client = Elasticsearch::Client.new
    ds = Pariah.connect(client)
    ds.should be_an_instance_of Pariah::Dataset
    proc { ds.client.info }.should_not raise_error
  end
end
