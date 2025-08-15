# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


gemfileを更新してbundle installした際
./bin/update_gems

docker-compose exec api bash

# モデルの作成
bundle exec rails generate model User name:string email:string:uniq
# マイグレーション
bundle exec rails db:migrate
# gemのインストール
bundle install