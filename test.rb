require 'yaml'
require_relative 'simple-googlespreadsheet-ruby/spreadsheet'

account = YAML.load_file('account.yaml')

spreadsheet_key = "0AlcQ3JEpuSzqdFNSVVFTcWlDSXI1dXZzdnBkQ0stLUE"

session = GoogleSpreadsheet.login(account['email'], account['password'])

ws = session.spreadsheet_by_key(spreadsheet_key).worksheets[0]

puts ws.title

p ws.row_count
ws << [Time.now.strftime('%F %T'), 60, 30]
p ws.row_count
