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
end
