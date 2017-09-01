# -*- encoding: UTF-8 -*-

require 'rails_helper'

describe Capybara::Session do
  subject { Capybara::Session.new(:webkit, @app) }
  after { subject.reset! }

  context "without meta charset" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html>
            <head>
            </head>
            <body>
              <div id="header">Список покупок</div>
              <table width="70%" cellpadding="2px" cellspacing="2px" border="1px" id="tbl">
                <thead>
                  <tr>
                    <th style="text-align:left;">Что купить</th>
                    <th>Количество</th>
                    <th>стоимсть, кр</th>
                    <th class="{sorter: false}">Действия</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Межгалактический щит</td>
                    <td>1</td>
                    <td>58</td>
                    <td><a href="#" class="delete">Удалить</a></td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        [200,
         { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
         [body]]
      end
    end

    it "invalid charset" do
      subject.visit "/"
      subject.should have_content "Список покупок" # Failed, returns "Ð¡Ð¿Ð¸ÑÐ¾Ðº Ð¿Ð¾"
    end
  end

  context "with meta charset" do
    before(:all) do
      @app = lambda do |env|
        body = <<-HTML
          <html>
            <head>
              <meta charset="utf-8">
            </head>
            <body>
              <div id="header">Список покупок</div>
              <table width="70%" cellpadding="2px" cellspacing="2px" border="1px" id="tbl">
                <thead>
                  <tr>
                    <th style="text-align:left;">Что купить</th>
                    <th>Количество</th>
                    <th>стоимсть, кр</th>
                    <th class="{sorter: false}">Действия</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Межгалактический щит</td>
                    <td>1</td>
                    <td>58</td>
                    <td><a href="#" class="delete">Удалить</a></td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        [200,
         { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
         [body]]
      end
    end

    it "valid charset" do
      subject.visit "/"
      subject.should have_content "Список покупок" # Good
    end
  end
end