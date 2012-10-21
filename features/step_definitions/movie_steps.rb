# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    m = Movie.find_by_title(movie[:title])
    if m.nil?
      Movie.create(:title => movie[:title], :rating => movie[:rating], :release_date => movie[:release_date])
    end
  end
end

Given /all ratings selected/i do
  Movie.all_ratings.each do |rating|
    check("ratings_" + rating)
  end

  visit('/movies?ratings%5BG%5D=1&ratings%5BNC-17%5D=1&ratings%5BPG%5D=1&ratings%5BPG-13%5D=1&ratings%5BR%5D=1')
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.

  bool = false
  if page.body.index(e1).nil? || page.body.index(e2).nil?
    bool = false
  else
    if page.body.index(e1) < page.body.index(e2)
      bool = true
    end
  end
  
  assert(bool, " -- Error sorting --")
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb

  if uncheck == 'un'
    rating_list.split(%r{,\s*}).each do |rating|
      steps %{When I uncheck "ratings_#{rating}"}
    end
  else
    rating_list.split(%r{,\s*}).each do |rating|
      steps %{When I check "ratings_#{rating}"}
    end
  end
end

Then /the following ratings should be checked: (.*)/ do |rating_list|
  bool = true

  rating_list.split(%r{,\s*}).each do |rating|
    if page.find_by_id("ratings_" + rating).checked?.to_s() != "checked"
      bool = false;
    end 
  end

  assert bool.should == true
end

Then /the following ratings should be unchecked: (.*)/ do |rating_list|
  bool = true
  
  rating_list.split(%r{,\s*}).each do |rating|
    if page.find_by_id("ratings_" + rating).checked?.to_s() == "checked"
      bool = false; 
    end
  end

  assert bool.should == true
end

Then /I should see rating "([^"]*)"$/ do |rating|
  bool = false

  Movie.find_by_rating(rating).nil
end   

Then /it should (not )?exists "([^"]*)"$/ do |exists, text|
  if exists.nil?
    assert Movie.find_by_title(text).nil? == false
  else
    assert Movie.find_by_title(text).nil? == true
  end
end

Then /I should see (all|none) of the movies/i do |count|
  if count = 'all' 
    #assert Movie.count.should == 10
    page.all('table#movies tr').count.should == 11
  else
    page.all('table#movies tr').count.should == 0
  end
end
