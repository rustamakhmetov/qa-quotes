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
    before do
      # fill local table
      Service.parse.each do |product|
        Product.create(product)
      end

      visit "http://tereshkova.test.kavichki.com"
      expect(page).to have_content("Список покупок")
    end

    fscenario 'compare tables without changes', js: true do
      results = get_products_site
      products = get_products_db
      expect(diff(products, results)).to eq []
    end

    scenario "add a new item into the remote table", js: true do
      item = {name: "New item", amount: 3, price: 55.5}
      add_new_item(item)

      results = get_products_site
      expect(results.count).to eq 5
      within "tbody tr:last-child" do
        within "td:nth-child(1)" do
          expect(page).to have_content(item[:name])
        end
        within "td:nth-child(2)" do
          expect(page).to have_content(item[:amount])
        end
        within "td:nth-child(3)" do
          expect(page).to have_content(item[:price])
        end
      end
    end

    scenario "compare tables with changes", js: true do
      item = {name: "New item", amount: 3, price: 55.5}
      add_new_item(item)

      results = get_products_site
      products = get_products_db
      expect(diff(products, results)).to eq [["+", "[#{results.count-1}]", item]]
    end

    scenario "delete existing rows", js: true do
      results = get_products_site
      expect(results.count).to be > 0
      item = results[0]
      within("table#tbl tbody tr:nth-child(1)") do
        within("td:nth-child(1)") do
          expect(page).to have_content(item[:name])
        end
        click_on "Удалить"
      end
      results.delete_at(0)
      new_results = get_products_site
      expect(diff(results, new_results)).to eq []
    end

    scenario "deleting a newly created record", js: true do
      item = {name: "New item", amount: 3, price: 55.5}
      add_new_item(item)
      results = get_products_site
      within "tbody tr:last-child" do
        within("td:nth-child(1)") do
          expect(page).to have_content(item[:name])
        end
        click_on "Удалить"
      end
      new_results = get_products_site
      expect(diff(results, new_results)).to eq [["-", "[#{results.count-1}]", item]]
    end

    scenario "reset remote table after her changed", js: true do
      item = {name: "New item", amount: 3, price: 55.5}
      results = get_products_site
      add_new_item(item)
      click_on "Сбросить"
      new_results = get_products_site
      expect(diff(results, new_results)).to eq []
    end
  end

end

def diff(list1, list2)
  HashDiff.best_diff(list1.sort_by {|e| e["name"] },
                     list2.sort_by {|e| e["name"] })
end

def get_products_db
  products = Product.all.map{|x| x.attributes.without("id", "created_at", "updated_at") }
  products.each do |e|
    e["price"] = e["price"].to_f
    e.symbolize_keys!
  end
  products
end

def get_products_site
  results = []
  page.all(:css, 'table#tbl tbody tr').each do |row|
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

def add_new_item(data)
  click_on "Добавить новое"
  fill_in "Название", with: data[:name]
  fill_in "Количество", with: data[:amount]
  fill_in "стоимость", with: data[:price]
  click_on "Добавить"
end