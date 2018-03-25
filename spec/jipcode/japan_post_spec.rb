RSpec.describe Jipcode::JapanPost do
  describe '#download_all' do
    subject { Jipcode::JapanPost.download_all }

    it '日本郵便のサイトからダウンロードした郵便番号データをファイルに保存する' do
      VCR.use_cassette('japan_post_zipcodes') do
        expect(File).to receive(:open).with('zipcode/general.zip', 'wb').once
        expect(File).to receive(:open).with('zipcode/company.zip', 'wb').once
        subject
      end
    end
  end
end
