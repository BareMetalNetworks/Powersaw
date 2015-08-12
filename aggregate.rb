#!/usr/bin/env ruby
require 'pp'
require 'hiredis'
require 'redis'
require 'redis-objects'
require 'activerecord'
require 'connection_pool'

Dir[File.dirname(__FILE__) + '../lib*.rb'].each do |file|
	require File.basename(file, File.extname(file))
end

$options = {}
$options[:host] = '10.0.1.17'
$options[:db] = 1
$options[:port] = '6379'
$options[:table] = 'system:log'


#ActiveRecord::Base.logger = Logger.new('log/db.log')
#	ActiveRecord::Base.configurations = YAML::load(IO.read('../config/database.yml'))
#end
#ActiveRecord::Base.establish_connection('development')
ActiveRecord::Base.establish_connection(
		:adapter => 'mysql2',
		:database => 'emergence',
		:username => 'emergence',
		:password => '#GDU3im=86jDFAipJ(f7*rTKuc',
		:host => 'datastore2')

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
	Redis.new({host: $options[:host], port: $options[:port], db: $options[:db]})}

$SHM = Redis::List.new('system:log', :marshall => true)

# Define a minimal database schema
ActiveRecord::Schema.define do
	create_table :documents, force: true do |t|
		t.integer :id
		t.string :name
		t.string :path

	end

	create_table :pages, force: true do |t|
		t.integer :id
		t.integer :pagenum
		t.integer :document_id
	end

	create_table :words, force: true do |t|
		t.integer :id
		t.string :term
		t.integer :page_id

	end

	add_index "wordlists", ["page_id"], :name=> "doc_pages_words"

end

# Define the models
class Document < ActiveRecord::Base
	has_many :pages
end

class Page < ActiveRecord::Base
	belongs_to :document # inverse_of: :foo, required: true
	has_many :words
end

class Words < ActiveRecord::Base
	belongs_to :page
end
