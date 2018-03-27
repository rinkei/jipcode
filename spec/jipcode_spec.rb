RSpec.describe Jipcode do
  it "has a version number" do
    expect(Jipcode::VERSION).not_to be nil
  end

  describe '.locate' do
    before(:all) do
      open("#{Jipcode::ZIPCODE_PATH}/xxx.csv", 'w') do |f|
        f.write("xxx0001,HOGE県,hoge市,ほげ\nxxx0001,FUGA県,fuga市,ふが\nxxx0002,PIYO県,piyo市,ぴよ")
      end
    end

    after(:all) do
      File.delete("#{Jipcode::ZIPCODE_PATH}/xxx.csv")
    end

    subject { Jipcode.locate(zipcode) }

    context '引数の郵便番号に対応する住所がない時' do
      let(:zipcode) { 'xxx0000' }

      it '空配列を返す' do
        is_expected.to eq []
      end
    end

    context '引数の郵便番号に対応する住所がある時' do
      let(:zipcode) { 'xxx0001' }

      it '対応する住所を全て含む配列を返す' do
        is_expected.to eq [
          { zipcode: 'xxx0001', prefecture: 'HOGE県', city: 'hoge市', town: 'ほげ' },
          { zipcode: 'xxx0001', prefecture: 'FUGA県', city: 'fuga市', town: 'ふが' }
        ]
      end
    end
  end

  describe '.search' do
    before(:all) do
      open("#{Jipcode::ZIPCODE_PATH}/xxx.csv", 'w') do |f|
        f.write("xxx0001,HOGE県,hoge市,ほげ\nxxx0001,FUGA県,fuga市,ふが\nxxx0002,PIYO県,piyo市,ぴよ")
      end
    end

    after(:all) do
      File.delete("#{Jipcode::ZIPCODE_PATH}/xxx.csv")
    end

    subject { Jipcode.search(zipcode) }

    context '引数の郵便番号に対応する住所がない時' do
      let(:zipcode) { 'xxx0000' }

      it '空配列を返す' do
        is_expected.to eq []
      end
    end

    context '引数の郵便番号に対応する住所がある時' do
      let(:zipcode) { 'xxx0001' }

      it '対応する住所を全て含む配列を返す' do
        is_expected.to eq [['xxx0001', 'HOGE県', 'hoge市', 'ほげ'], ['xxx0001', 'FUGA県', 'fuga市', 'ふが']]
      end
    end
  end
end
