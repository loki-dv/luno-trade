# Add ruby gem for the Luno interacting
require 'bitx'

# Add variables from .env file
require 'dotenv'
Dotenv.load

# Add json support
require 'json'

# baner
puts '=' * 80
puts '=' * 34 + ' Luno Trade ' + '=' * 34
puts '=' * 80
# Load config
BitX.configure do |config|
  config.api_key_secret = ENV['API_KEY_SECRET']
  config.api_key_id = ENV['API_KEY_ID']
end

# Balance information section
balance = BitX.balance
puts 'Current balance:'
puts 'EUR: ' + balance[0][:balance].to_f.round(2).to_s + ' (reserved: ' + \
     balance[0][:reserved].to_f.round(2).to_s + ', available: ' + \
     balance[0][:available].to_f.round(2).to_s + ')'
puts 'BTC: ' + balance[1][:balance].to_f.to_s + ' (reserved: ' + \
     balance[1][:reserved].to_f.to_s + ', available: ' + \
     balance[1][:available].to_f.to_s + ')'

# Orders information section
puts '=' * 80
puts 'My current orders:'
p_orders = BitX.list_orders(ENV['TICKER'])
p_orders.each do |order|
  if order[:state] == 'PENDING'
    puts order[:order_id] + ': ' + order[:type].to_s + ' ' + \
         order[:limit_price].to_f.to_s + ' ' + order[:limit_volume].to_f.to_s
  end
end

# Parse command line args
puts '=' * 80
if ARGV.length == 0
  # nothing to parse
  puts 'No command, exit'
  exit 0
elsif
  ARGV.length >= 1
  puts 'Will be processed command ' + ARGV[0]
end
