# Jipcode

Jipcodeは郵便番号から住所を検索する機能を提供します。
郵便番号と対応する住所のデータは日本郵便の公式サイトで配布されているものを用いています。

## Usage

### 検索
郵便番号は1個の番号につき複数の住所が結びつくことがあります。
そのため次のように検索結果は二重配列で返ります。
内部の住所情報を要素とする配列は郵便番号、都道府県、市区町村、町域番地の順になっています。

```ruby
Jipcode.search('1510051')
# => [["1510051", "東京都", "渋谷区", "千駄ヶ谷"]]
```

### 更新
日本郵便の郵便番号データは月末に更新されています。
これを取り込むには次のRakeタスクを実行してください。

```ruby
$ bundle exec rake update
```

郵便番号データのダウンロードと取り込みを分けることもできます。

```shell
$ bundle exec rake download # 郵便番号データのダウンロード
$ bundle exec rake import   # 郵便番号データの取り込み
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jipcode project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rinkei/jipcode/blob/master/CODE_OF_CONDUCT.md).
