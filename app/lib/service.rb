require 'open-uri'
require 'nokogiri'

class Service
  def self.parse
    results = []
    url = 'http://tereshkova.test.kavichki.com'
    html = open(url)
    doc = Nokogiri::HTML(html, nil, 'utf-8')

    doc.css('table#tbl tbody tr').each do |row|
      td = row.css('td')
      name = td[0].text
      next unless name
      data = {name: name,
              amount: td[1].text.to_i,
              price: td[2].text.to_f}
      results << data
    end
    results
  end
end