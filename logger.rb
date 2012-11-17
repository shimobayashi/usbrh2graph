require 'yaml'
require_relative 'simple-googlespreadsheet-ruby/spreadsheet'
require_relative 'USBMeter'

account = YAML.load_file('account.yaml')
spreadsheet_key = "0AlcQ3JEpuSzqdFNSVVFTcWlDSXI1dXZzdnBkQ0stLUE"
session = GoogleSpreadsheet.login(account['email'], account['password'])
ws = session.spreadsheet_by_key(spreadsheet_key).worksheets[0]

begin
  devices = RHDevices.new
  device = nil
  devices.each {|d| device = d}
  if device
    puts "name                 : #{device.name}"
    puts "version              : #{device.version}"

    while true
      begin
        now = Time.now.strftime('%F %T')
        t,h = device.getTempHumidTrue
        redo unless t and h
        puts "now                  : #{now}"
        puts "corrected temperature: #{t}"
        puts "corrected humidity   : #{h}"
        ws << [now, h, t]
        sleep 60 * 60
      rescue Exception
        puts "Exception: #{$!.message}"
        puts $1.backtrace
        retry
      end
    end
  end
rescue => exc
  puts "Exception: #{$!.message}"
  puts $1.backtrace
  puts 'wait 60sec...'
  sleep 60
  retry
end
