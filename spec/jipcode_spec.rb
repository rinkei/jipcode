RSpec.describe Jipcode do
  it "has a version number" do
    expect(Jipcode::VERSION).not_to be nil
  end

  describe '.locate' do
    before(:all) do
      open("#{Jipcode::ZIPCODE_PATH}/000.csv", 'w') do |f|
        f.write("0000001,HOGE県,hoge市,ほげ\n0000001,FUGA県,fuga市,ふが\n0000002,PIYO県,piyo市,ぴよ")
      end
    end

    after(:all) do
      File.delete("#{Jipcode::ZIPCODE_PATH}/000.csv")
    end

    subject { Jipcode.locate(zipcode) }

    context '引数の郵便番号に対応する住所がない時' do
      let(:zipcode) { '0000000' }

      it '空配列を返す' do
        is_expected.to eq []
      end
    end

    context '引数の郵便番号に対応する住所がある時' do
      let(:zipcode) { '0000001' }

      it '対応する住所を全て含む配列を返す' do
        is_expected.to eq [
          { zipcode: '0000001', prefecture: 'HOGE県', city: 'hoge市', town: 'ほげ', prefecture_code: nil },
          { zipcode: '0000001', prefecture: 'FUGA県', city: 'fuga市', town: 'ふが', prefecture_code: nil }
        ]
      end

      context 'prefecture_code.yml に対応する都道府県がある時' do
        let(:zipcode) { '1000000' }

        it '対応する prefecture_code も含む配列を返す' do
          is_expected.to eq [
            { zipcode: '1000000', prefecture: '東京都', city: '千代田区', town: nil, prefecture_code: 13 }
          ]
        end
      end
    end
  end
end
