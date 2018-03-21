RSpec.describe Jipcode do
  it "has a version number" do
    expect(Jipcode::VERSION).not_to be nil
  end

  describe '.search' do
    before(:all) do
      Dir.mkdir("#{Jipcode::ZIPCODE_PATH}/xxx")
      open("#{Jipcode::ZIPCODE_PATH}/xxx/0001.csv", 'w') do |f|
        f.write("HOGE県,hoge市,ほげ\nFUGA県,fuga市,ふが")
      end
    end

    after(:all) do
      FileUtils.rm_rf("#{Jipcode::ZIPCODE_PATH}/xxx")
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
        is_expected.to eq [['HOGE県', 'hoge市', 'ほげ'], ['FUGA県', 'fuga市', 'ふが']]
      end
    end
  end
end
