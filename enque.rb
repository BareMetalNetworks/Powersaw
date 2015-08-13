#!/usr/bin/env ruby
require 'redis'
require 'redis-objects'
require 'connection_pool'
require 'logger'

### Enque logs onto redis list for processing by a central node

$options = {}
$options[:host] = '10.0.1.17'
$options[:db] = 1
$options[:port] = '6379'
$options[:table] = 'system:log'
$options[:hookLog] = '/var/log/syslog'

$DEBUG = true
$logger = Logger.new('enque.log', 'a')

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
	Redis.new({host: $options[:host], port: $options[:port], db: $options[:db]})}

$r = Redis::List.new('system:log', :marshall => true, :expiration => 5)

begin
open($options[:hookLog]) do |file|
	file.seek(0, IO::SEEK_END)
	loop do
		changes = file.read
		unless changes.empty?
			p "#{Time.now} #{changes}" if $DEBUG
		$logger.info "#{Time.now}: Logged -> #{changes}"

			$r << changes
		end
	 sleep 10
	end
end

rescue => err
	$logger.info "#{Time.now}: Error #{err.inspect}\n Backtrace #{err.backtrace}"
	sleep 300
	retry
end
