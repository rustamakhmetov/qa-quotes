# README

Пример тестирования внешнего сайта с применением Rspec, Capybara.

**Порядок настройки проекта**

_В папке проекта:_
0. rvm use 2.4.0@qa-quotes --create
1. gem install bundle
2. bundle install
3. config/database.yml.sample переименовать в config/database.yml, указать в нем параметры подключения к серверу Postgresql (секция: default)
4. rake db:create
5. rake db:migrate 
6. запускаем "rspec spec/", ждем выполнения

Для отключения показа окна браузера при тестировании, необходимо в файле "spec/acceptance/acceptance_helper.rb" закомментировать строки с 12 по 15.