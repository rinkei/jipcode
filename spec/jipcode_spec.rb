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
          { zipcode: '0000001', prefecture: 'HOGE県', city: 'hoge市', town: 'ほげ' },
          { zipcode: '0000001', prefecture: 'FUGA県', city: 'fuga市', town: 'ふが' }
        ]
      end
    end
  end

  describe '.locate_by_address' do
    before(:all) do
      open("#{Jipcode::AddressLocator::PREFECTURE_PATH}/0.csv", 'w') do |f|
        f.write <<~CSV
          0000001,HOGE県,hoge市,ほげ町
          0000002,HOGE県,hoge市,ほげ町ホゲ
          0000003,HOGE県,piyo市,ぴよ
        CSV
      end
    end

    after(:all) do
      File.delete("#{Jipcode::AddressLocator::PREFECTURE_PATH}/0.csv")
    end

    subject { Jipcode.locate_by_address(address) }

    context '引数の住所に対応する都道府県がない時' do
      let(:address) { 'FOO県BAR市BAZ' }

      it '空配列を返す' do
        is_expected.to eq []
      end
    end

    context '引数の住所に対応する都道府県があり' do
      before do
        allow(Jipcode::AddressLocator).to receive(:prefecture_code).with(address).and_return(0)
      end
      context 'さらに対応する住所がある時' do
        let(:address) { 'HOGE県hoge市ほげ町ホゲ１ー１' }
        it '対応する住所を配列を似ている順に返す' do
          is_expected.to eq [
            { zipcode: '0000002', prefecture: 'HOGE県', city: 'hoge市', town: 'ほげ町ホゲ', distance: 0.9666666666666667 },
            { zipcode: '0000001', prefecture: 'HOGE県', city: 'hoge市', town: 'ほげ町', distance: 0.9444444444444444 }
          ]
        end
      end

      context 'さらに対応する住所がない時' do
        let(:address) { 'HOGE県hoge市フガ町ホゲ１ー１' }
        it '対応する住所を配列を似ている順に返す' do
          is_expected.to eq []
        end
      end
    end
  end
end
