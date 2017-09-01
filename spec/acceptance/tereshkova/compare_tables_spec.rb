require 'acceptance/acceptance_helper'
require 'curb'

feature 'Accept answer', %q{
  In order to be able to accept right answer solved problem
  As an author of question
  I want to be able to accept an answer to the question
} do
  describe 'Compare local and remote tables' do


    # given(:question) { create(:question) }
    # given(:user) { question.user  }
    # given!(:other_user) { create(:user) }
    # given!(:answer) { create(:answer, question: question, user: other_user, body: "Answer [accept]") }
    # given!(:answer2) { create(:answer, question: question, user: other_user) }
    # given!(:answer3) { create(:answer, question: question, user: other_user, accept: true) }
    #
    # before do
    #   sign_in user
    #   visit question_path(question)
    # end
    # before do
    #   Capybara.current_driver = :selenium
    # end

    #Capybara.run_server = false
    subject { Capybara::Session.new(:webkit, @app) }
    after { subject.reset! }

    before(:all) do
      @app = lambda do |env|
        url = 'http://tereshkova.test.kavichki.com'
        http = Curl.get(url)
        body = http.body_str.force_encoding("UTF-8")
        body["<head>"]='<head><meta charset="utf-8">'
        [200,
         { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
         [body]]
      end
    end


    scenario 'see remote table', js: true do

      # url = 'http://tereshkova.test.kavichki.com'
      # http = Curl.get(url)
      # body = http.body_str.force_encoding("UTF-8")
      # a=1
      #
      # html = open(url)
      # doc = Nokogiri::HTML(html, nil, 'utf-8')
      #
      # Capybara.default_selector = :css

      # class Japan < Rack::Proxy
      #   def rewrite_env(env)
      #     env['HTTP_HOST'] = 'l-tike.com'
      #     env
      #   end
      # end
      #
      # session = Capybara::Session.new(:rack_test, Japan.new)
      # session.visit 'http://tereshkova.test.kavichki.com'
      # puts session.body
      # subject.visit "http://tereshkova.test.kavichki.com"
      # return

      subject.visit "/"
      text = subject.text
      text2 = page.text.encode("utf-8")
      #text.encode( 'UTF-8', 'Windows-1252')
      #doc = Nokogiri::HTML(page.body, nil, 'utf-8')
      expect(page).to have_content("Список покупок")
      #page.first(:xpath, id).text.encode('iso-8859-15')
      # within '.answers' do
      #   expect(page).to have_link('Accept')
      # end
    end
  end
end