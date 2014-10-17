require 'spec_helper'

describe Fracas::Dataset, '#filter' do
  it "should add a filter to the search" do
    store body: {title: "Title 1", comments_count: 5}
    store body: {title: "Title 2", comments_count: 9}
    FTS.refresh

    titles = []
    FTS.filter(comments_count: 5).each do |doc|
      titles << doc['title']
    end
    titles.sort.should == ["Title 1"]
  end

  it "should return a new copy of the dataset" do
    ds1 = FTS.filter(comments_count: 5)
    ds1.query[:filters].should == [{comments_count: 5}]

    ds2 = ds1.filter(title: "The Joy of Ferrets")
    ds2.query[:filters].should == [{comments_count: 5}, {title: "The Joy of Ferrets"}]

    ds1.query[:filters].should == [{comments_count: 5}]
  end
end
