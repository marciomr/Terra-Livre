# coding: utf-8

require File.dirname(__FILE__) + '/../spec_helper'

feature "Auto-fill form", %q{
  In order to have an awesome library
  As a logged user
  When the book exists in google books or in the library the form should be auto-filled
  } do

  background do
    @user = create(:user)
    login(@user)
  end

  scenario "google books without javascript" do
    faweb_register_book('gbook-proudhon.xml', '1606802127')
    google_book_test
  end
  
  scenario "google books with javascript", :js do
    google_book_test
  end
  
  scenario "auto-fill with other user's books without javascript" do
    faweb_register_book('gbook-empty.xml', '1234567890')
    auto_fill_test
  end
  
  scenario "auto-fill with other user's books with javascript", :js do
    auto_fill_test
  end
end

def auto_fill_test
  book = create(:book, :isbn => 1234567890)
  author = create(:author, :book_id => book.id)
  visit new_user_book_path(@user)
    
  fill_in "isbn", :with => book.isbn
  click_button "Preencher"

  sleep 2

  %w(title subtitle country city).each do |f|
    find(:field, "book_#{f}").value.should have_content(book.send(f))
  end
  find(:css, '.book_author').value.should have_content(book.authors.first.name)
end

def google_book_test
  visit new_user_book_path(@user)
  fill_in "isbn", :with => 1606802127
  click_button "Preencher"
  
  sleep 2
  
  find(:field, 'book_title').value.should have_content("What Is Property")
  find(:field, 'book_subtitle').value.should have_content("An Inquiry Into The Principle Of Right And Of Government")
  find(:css, '.book_author').value.should have_content("Pierre Joseph Proudhon")
  find(:field, 'book_editor').value.should have_content("Forgotten Books")
  find(:field, 'book_language').value.should have_content("En")
  find(:field, 'book_page_number').value.should have_content("457")
end

