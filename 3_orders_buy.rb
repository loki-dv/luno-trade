# Add ruby gem for the Luno interacting
require 'bitx'

# Add variables from .env file
require 'dotenv'
Dotenv.load

# Add json support
require 'json'

# Add double type
require 'bigdecimal'
require 'bigdecimal/util'

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
buy_orders = Array.new
puts '=' * 80
puts 'My current orders:'
p_orders = BitX.list_orders(ENV['TICKER'])
p_orders.each do |order|
  if order[:state] == 'PENDING'
    if order[:type] == :BID
      buy_orders.push(order[:order_id])
    end
    puts order[:order_id] + ': ' + order[:type].to_s + ' ' + \
         order[:limit_price].to_f.to_s + ' ' + order[:limit_volume].to_f.to_s
  end
end

# Parse command line args
puts '=' * 80
if ARGV.empty?
  # nothing to parse
  puts 'No command detected, exit'
  exit 0
else
  command = ARGV[0]
  puts 'Will be processed command ' + ARGV[0]
  ARGV.shift
end

until ARGV.empty?
  next unless ARGV.first.start_with?('-')
  case ARGV.shift
  when '-c', '--corner', '--corner-price', '--corner_price', \
       '-corner', '-corner-price', '-corner_price'
    corner_price = ARGV.shift
  when '-v', '--volume', '-volume'
    volume = ARGV.shift
  end
end

def fold(buy_orders)
  unless buy_orders.empty?
    buy_orders.each do |order|
      puts 'Will be canceled BID-order with ID ' + order
      puts 'Success' if BitX.stop_order(order)[:success] == true
    end
  end
  return 0
end

case command
  when 'fold'
    fold(buy_orders)
  when 'renew'
    fold(buy_orders)
    corner_price = BitX.ticker(ENV['TICKER'])[:bid].to_f.round(2) if corner_price.nil?
    puts 'Corner price: ' + corner_price.to_s
    volume = (balance[0][:balance].to_f.round(2) / (corner_price * 10)).round(4) if volume.nil?
    puts 'Volume: ' + volume.to_s
    # First order - V = volume, P = corner_price - 1%
    BitX.post_order('BID', volume, (corner_price*0.99).round(2), ENV['TICKER'])
    # Second order - V = volume*1.5, P = corner_price-3%
    BitX.post_order('BID', (volume*1.5).round(4), (corner_price*0.97).round(2), ENV['TICKER'])
    # Second order - V = volume*2, P = corner_price-5%
    BitX.post_order('BID', (volume*2).round(4), (corner_price*0.95).round(2), ENV['TICKER'])
  end
