require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'jipcode/japan_post'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc '日本郵便から全郵便番号データをダウンロードし、ローカルに取り込む'
task :update do
  Jipcode::JapanPost.update
end

namespace :update do
  desc '日本郵便から全郵便番号データをダウンロードする'
  task :download do
    Jipcode::JapanPost.download_all
  end

  desc '日本郵便の全郵便番号データをローカルに取り込む'
  task :import do
    Jipcode::JapanPost.import_all
  end
end
