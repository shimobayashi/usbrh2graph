require 'yaml'
require_relative 'simple-googlespreadsheet-ruby/spreadsheet'
require_relative 'USBMeter'

account = YAML.load_file('account.yaml')
spreadsheet_key = "0AlcQ3JEpuSzqdFNSVVFTcWlDSXI1dXZzdnBkQ0stLUE"
session = GoogleSpreadsheet.login(account['email'], account['password'])
ws = session.spreadsheet_by_key(spreadsheet_key).worksheets[0]

devices = RHDevices.new
devices.each do |device|
  puts "name                 : #{device.name}"
  puts "version              : #{device.version}"

  while true
    now = Time.now.strftime('%F %T')
    t,h = device.getTempHumidTrue
    puts "now                  : #{now}"
    puts "corrected temperature: #{t}"
    puts "corrected humidity   : #{h}"
    ws << [now, h, t]
    sleep 60 * 60
  end
end
