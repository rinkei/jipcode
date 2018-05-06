[![Build Status](https://travis-ci.org/rinkei/jipcode.svg?branch=master)](https://travis-ci.org/rinkei/jipcode)

# Jipcode

Jipcodeは郵便番号から住所を検索する機能を提供します。
郵便番号と対応する住所のデータは日本郵便の公式サイトで配布されているものを用いています。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jipcode'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install jipcode
```

## Usage

### 検索
郵便番号は1個の番号につき複数の住所が結びつくことがあります。
そのため次のように検索結果は住所情報を含むHashの配列で返ります。
このHashは郵便番号(`:zipcode`)、都道府県(`:prefecture`)、市区町村(`:city`)、町域番地(`:town`)の値を持ちます。

```ruby
Jipcode.locate('1510051')
# => [{zipcode: '1510051', prefecture: '東京都', city: '渋谷区', town: '千駄ヶ谷'}]
```

### 更新
日本郵便の郵便番号データは月末に更新されています。
jipcodeではこれを毎月取り込んでいます。

更新を反映したい時は`bundle update jipcode`してください。

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jipcode project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rinkei/jipcode/blob/master/CODE_OF_CONDUCT.md).
