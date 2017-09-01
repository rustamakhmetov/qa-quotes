require 'acceptance/acceptance_helper'
require 'curb'

class Hash
  def without(*keys)
    dup.without!(*keys)
  end

  def without!(*keys)
    reject! { |key| keys.include?(key) }
  end
end


feature 'Compare tables' do
  describe 'Compare local and remote tables' do
    subject { Capybara::Session.new(:webkit, @app) }
    after { subject.reset! }

    before(:all) do
      # fill local table
      Service.parse.each do |product|
        Product.create(product)
      end

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


    scenario 'compare tables without changes', js: true do
      subject.visit "/"
      page = subject.body
      expect(page).to have_content("Список покупок")

      results = []
      subject.all(:css, 'table#tbl tbody tr').each do |row|
        td = row.all(:css, 'td')
        name = td[0].text
        next unless name
        data = {name: name,
                amount: td[1].text.to_i,
                price: td[2].text.to_f}
        results << data
      end
      products = Product.all.map{|x| x.attributes.without("id", "created_at", "updated_at") }
      products.each do |e|
        e["price"] = e["price"].to_f
        e.symbolize_keys!
      end
      products.sort_by! {|e| e["name"] }
      results.sort_by! {|e| e["name"] }

      expect(HashDiff.best_diff(products, results)).to eq []
    end

    fscenario "add a new item into the remote table", js: true do
      subject.visit "/"
      page = subject.body
      expect(page).to have_content("Список покупок")
      subject.click_on "Добавить новое"
      subject.fill_in "Название", with: "New item"
      subject.fill_in "Количество", with: 5
      subject.fill_in "стоимость", with: 55.5
      subject.click_on "Добавить"
      products = get_products(subject)
      expect(products.count).to eq 5 # Failed
      #subject.save_and_open_page
    end
  end
end

def get_products(subj)
  results = []
  subj.all(:css, 'table#tbl tbody tr').each do |row|
    td = row.all(:css, 'td')
    name = td[0].text
    next unless name
    data = {name: name,
            amount: td[1].text.to_i,
            price: td[2].text.to_f}
    results << data
  end
  results
end