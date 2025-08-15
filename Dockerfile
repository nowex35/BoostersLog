FROM ruby:3.3

WORKDIR /service
# ルートディレクトリにあるGemfileとGemfile.lockをコピー
COPY Gemfile* /service/
RUN bundle install
EXPOSE 3000

# Railsサーバーを起動
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
