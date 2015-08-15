#!/usr/bin/env ruby
require 'redis'
require 'redis-objects'
require 'connection_pool'
require 'logger'
require 'thread'
require 'rb-inotify'
# Cuz shes my log hooker... yeaa yeaaaaaaa... my log hooker!

$options = {}

$options[:host] = '10.0.1.17'
$options[:db] = 1
$options[:port] = '6379'
$options[:table] = 'system:log'
$options[:hookLog] = '/var/log/syslog'

$DEBUG = true
$logger = Logger.new('enque.log', 'a+')

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
	Redis.new({host: $options[:host], port: $options[:port], db: $options[:db]})}

$r = Redis::List.new('system:log', :marshall => true, :expiration => 5)

$r = Redis::List.new('system:log:archive', :marshall => true)




#dirHookEtc = Thread.new{


 #begin
	hook = INotify::Notifier.new
    tim = "#{Time.now}: "
    fil = " Filename: #{event.name} "
		 p "Event name: #{event.name} \n Event Methods: #{event.methods.sort}"
		 if event.flags.include? :create
			     $r << "#{tim} File created. #{fil}"
		 end

		 if event.flags.include? :delete
			  $r << "#{tim} File deleted. #{fil}"
			  $archive << "#{tim} #{fil} : Deleted"
		 end

		 if event.flags.include? :modify
			 $r << "#{tim} File #{fil} : Was modified"
			 $archive << "#{tim} #{fil} : Modified"

		 end
		 sleep 5
	end

# rescue => err
#	$logger.info "#{Time.now}: #{err.inspect} backtrace: #{err.backtrace}"
 #end


#}

#dirHookEtc.Thread.join

#logHook.Thread.join


__END__
#def hook_log_file
## this is the file hook thread
#logHook = Thread.new{
#begin
# open($options[:hookLog]) do |file|
# 	file.seek(0, IO::SEEK_END)
# 	loop do
# 		changes = file.read
# 		unless changes.empty?
# 			p "#{Time.now} #{changes}" if $DEBUG
# 		$logger.info "#{Time.now}: Logged -> #{changes}"
#
# 			$r << changes
# 		end
# 	 sleep 10
# 	end
# end

#rescue => err
#	$logger.info "#{Time.now}: Error #{err.inspect}\n Backtrace #{err.backtrace}"
#	sleep 300
#	retry
#end
#cephlexin}
#	end

