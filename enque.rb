#!/usr/bin/env ruby
require 're is'
require 'redis-objects'
require 'connection_pool'
require 'logger'
require 'thread'
require 'rb-inotify'

$options = {}

$options[:host] = '10.0.1.17'
$options[:db] = 1
$options[:port] = '6379'
$options[:table] = 'system:log'
$options[:hookLog] = '/var/log/syslog'

$DEBUG = true
$logger = Logger.new('enque.log', 'a+')

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
	Redis.new({host: $options[:host], port: $options[:port], db: $options[:db], logger: true})}

$r = Redis::List.new('system:log', :marshal => true, :expiration => 5)
$spool = Redis::List.new('system:log:spool', :marshal => true)  # for end of day mailer

$archive = Redis::List.new('system:log:archive', :marshal => true)

def mailer(msg, address)
	sleep 5
	`echo #{msg} | /usr/bin/ssmtp #{address}`

end

def bench(name)
 elapsed =  Benchmark.realtime {yield}
 return "%s: %.2fs" % [name, elapsed]
  end

def forker(brock)
pid = fork do
	yield
end
Process.detach(pid)
end

$resultFactory = lambda  {|x,y|  return "#{Time.now}: File #{x}, #{y} action(s) have been executed as a result" }



def parser event
	tim = "#{Time.now}: "
	fil = " Filename: #{event.name} "
	if event.flags.include? :create #, :access
		$r << "#{tim} File created: #{fil}"
	end

	if event.flags.include? :delete
		$r << "#{tim} File deleted: #{fil}"
		$archive << "#{tim} #{fil}: Deleted"
		sleep 5
		mailer(message, "transiencymail@gmail.com")
		sleep 5
		mailer(message, "support@baremetalnetworks.com")

	end

	if event.flags.include? :modify
		$r << "#{tim} File #{fil} : Was modified"
		$archive << "#{tim} #{fil} : Modified"

	end
	if event.flags.include? :moved_from
		$r << "#{tim} File #{fil} : Was modified"
		$archive << "#{tim} #{fil} : Modified"

	end
	if event.flags.include? :access
		$r << "#{tim} File #{fil} : Was modified"
	end
end



begin

	while true do


#dirHookEtc = Thread.new{

		end

 #begin
	hook = INotify::Notifier.new
		hook.watch("/etc/", :create, :delete, :modify, :access, :moved_from) do |event|



		 p "Event name: #{event.name} \n Event Methods: #{event.methods.sort}"
	   parser(event)
		 sleep 5
		end

	hook.run

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
#}
#	end

