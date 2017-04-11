require 'spec_helper'

describe Pariah, '.connect' do
  it "should instantiate a Pariah::Dataset instance" do
    ds = Pariah.connect
    assert_instance_of Pariah::Dataset, ds
    ds.client.info # Doesn't raise error
  end

  it "should accept an already existing Elasticsearch::Transport::Client instance" do
    client = Elasticsearch::Client.new
    ds = Pariah.connect(client)
    assert_instance_of Pariah::Dataset, ds
    ds.client.info # Doesn't raise error
  end
end
