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
# If ETH wallet is enable, we have three balances:
# ETH
# EUR
# BTC
# without ETH:
# EUR
# BTC
eur_idx = 1
btc_idx = 2
puts 'Current balance:'
puts 'EUR: ' + balance[eur_idx][:balance].to_f.round(2).to_s + \
     ' (reserved: ' + balance[eur_idx][:reserved].to_f.round(2).to_s + \
     ', available: ' + balance[eur_idx][:available].to_f.round(2).to_s + ')'
puts 'BTC: ' + balance[btc_idx][:balance].to_f.to_s + ' (reserved: ' + \
     balance[btc_idx][:reserved].to_f.to_s + ', available: ' + \
     balance[btc_idx][:available].to_f.to_s + ')'
# Orders information section
buy_orders = Array[]
sell_orders_prices = Array[]
puts '=' * 80
puts 'My current orders:'
p_orders = BitX.list_orders(ENV['TICKER'], state: 'PENDING')
p_orders.each do |order|
  if order[:type] == :BID
    buy_orders.push(order[:order_id])
  else
    sell_orders_prices.push(order[:limit_price])
  end
  puts order[:order_id] + ': ' + order[:type].to_s + ' ' + \
       order[:limit_price].to_f.to_s + ' ' + order[:limit_volume].to_f.to_s
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
end

# Check variables function
def check_var(global, default)
  if global.nil?
    result = default
  else
    result = global.to_f
  end
  return result
end

# Orders send function
def orders_send(volume, corner_price)
  # First order - V = volume, P = corner_price - 1% by default
  price_multiplier = check_var(ENV['1ST_BUY_ORDER_PRICE'], 0.99)
  local_price = (corner_price*price_multiplier).round(2)
  if ENV['1ST_BUY_ORDER_VOLUME_PERC'].nil?
    local_volume = check_var(ENV['1ST_BUY_ORDER_VOLUME'], volume).round(4)
  else
    local_volume = ((volume / ENV['MM_BUY_ORDER_PERC'].to_f) * ENV['1ST_BUY_ORDER_VOLUME_PERC'].to_f).round(4)
  end
  puts "Will be send BID order with price #{local_price} (#{price_multiplier}) and volume #{local_volume}"
  result = BitX.post_order('BID', local_volume, local_price, ENV['TICKER'])
  puts 'Success' unless result[:order_id].nil?
  # Second order - V = volume*1.5, P = corner_price-3% by default
  price_multiplier = check_var(ENV['2ND_BUY_ORDER_PRICE'], 0.97)
  local_price = (corner_price*price_multiplier).round(2)
  if ENV['2ND_BUY_ORDER_VOLUME_PERC'].nil?
    local_volume = check_var(ENV['2ND_BUY_ORDER_VOLUME'], volume*1.5).round(4)
  else
    local_volume = ((volume / ENV['MM_BUY_ORDER_PERC'].to_f) * ENV['2ND_BUY_ORDER_VOLUME_PERC'].to_f).round(4)
  end
  puts "Will be send BID order with price #{local_price} (#{price_multiplier}) and volume #{local_volume}"
  result = BitX.post_order('BID', local_volume, local_price, ENV['TICKER'])
  puts 'Success' unless result[:order_id].nil?
  # Second order - V = volume*2, P = corner_price-5% by default
  price_multiplier = check_var(ENV['3RD_BUY_ORDER_PRICE'], 0.95)
  local_price = (corner_price*price_multiplier).round(2)
  if ENV['3RD_BUY_ORDER_VOLUME_PERC'].nil?
    local_volume = check_var(ENV['3RD_BUY_ORDER_VOLUME'], volume*2).round(4)
  else
    local_volume = ((volume / ENV['MM_BUY_ORDER_PERC'].to_f) * ENV['3RD_BUY_ORDER_VOLUME_PERC'].to_f).round(4)
  end
  puts "Will be send BID order with price #{local_price} (#{price_multiplier}) and volume #{local_volume}"
  result = BitX.post_order('BID', local_volume, local_price, ENV['TICKER'])
  puts 'Success' unless result[:order_id].nil?
end

# Commands
case command
  when 'fold'
    fold(buy_orders)
  when 'renew'
    fold(buy_orders)
    sleep(3)
    avg_sell_price = ((sell_orders_prices.sum.to_f / sell_orders_prices.size.to_f - ENV['SELL_ORDER_DISTANCE'].to_f) * 1.01).to_f.round(2)
    corner_price = BitX.ticker(ENV['TICKER'])[:bid].to_f.round(2) if corner_price.nil?
    corner_price = avg_sell_price if corner_price > avg_sell_price
    puts 'Corner price: ' + corner_price.to_s
    volume = ((balance[eur_idx][:balance].to_f.round(2) * (ENV['MM_BUY_ORDER_PERC'].to_f * 0.01)) / corner_price).round(4) if volume.nil?
    puts 'Corner volume: ' + volume.to_s
    orders_send(volume, corner_price)
end
