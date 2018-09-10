# Luno Trade Project

## Install gems

Install required gems:

```
gem install bitx
gem install dotenv
```

## Set 3 BUY orders 

* Define which distance will be used and how it will be requirements of the current price (for example: we get the current price, set the first order below on 1% the current BID price, the second order below on 3% the current BID price and the third order below on 5% the current BID price; if we will have the BID price 5000 EUR, the first order will be placed on 4950, the second order will be placed on 4850 and the third order will be placed on 4750).
* Define a money-management rules for calculate volume of orders.
* Add simple analytic functions

## Close open position

* Get the BTC balance
* Define a money-management for calculating the best volume of position
* Define volume of EUR profit

## Periodically

* Define a time politics

## 3 orders buy - Usage

### Generaly usage:

```
ruby 3_orders_buy.rb [COMMAND] [PARAMETERS]
```

Available commands: 'fold', 'renew'

### Just information output

For information output just run a script without a commant and parameters:

```
ruby 3_orders_buy.rb
```

### Close/cancel all previously BID orders

For closing all previously opened buy orders just run a script with command 'fold':

```
ruby 3_orders_buy.rb fold
```

### Close/cancel all previously BID orders if exist and then open new orders:


```
ruby 3_orders_buy.rb renew
```

Parameters:
* -corner_price - the price for calculating BID prices for new orders
* -volume - the volume of the FIRST order of three, the price of the second order will be volume*1.5, the price of the third order will be volume*2 (TODO: add variables to ENV for this)

Without parameters we will use:
* Last BID order price in order book instead corner_price argument
* 1/10 from deposit in EUR as volume in EUR and deposit/(corner_price*10) and apply round(4)


## ENV variables:

Sample of config file:

```API_KEY_ID=abcdefg12345
API_KEY_SECRET=abcdefghijklmnopqrstuvwxyz0123456789
TICKER=XBTEUR
1ST_BUY_ORDER_PRICE=0.95
2ND_BUY_ORDER_PRICE=0.93
3RD_BUY_ORDER_PRICE=0.91
#1ST_BUY_ORDER_VOLUME=0.0005
#2ND_BUY_ORDER_VOLUME=0.001
#3RD_BUY_ORDER_VOLUME=0.0015
1ST_BUY_ORDER_VOLUME_PERC=10
2ND_BUY_ORDER_VOLUME_PERC=20
3RD_BUY_ORDER_VOLUME_PERC=30
SELL_ORDER_DISTANCE=350
MM_BUY_ORDER_PERC=10
```

* API_KEY_ID - API key from Luno
* API_KEY_SECRET - API key secret
* TICKER - ticker
* 1ST_BUY_ORDER_PRICE - it is a multiplier to the corner_price for the first order (default 0.99)
* 2ND_BUY_ORDER_PRICE - it is a multiplier to the corner_price for the second order (default 0.97)
* 3RD_BUY_ORDER_PRICE - it is a multiplier to the corner_price for the third order (default 0.95)
* One of:
  * 1ST_BUY_ORDER_VOLUME - it is a volume of the first order OR
  * 1ST_BUY_ORDER_VOLUME_PERC - it is a volume of the first order in percentage
* One of:
  * 2ND_BUY_ORDER_VOLUME - it is a volume of the second order OR
  * 2ND_BUY_ORDER_VOLUME_PERC - it is a volume of the second order in percentage
* One of:
  * 3RD_BUY_ORDER_VOLUME - it is a volume of the third order OR
  * 3RD_BUY_ORDER_VOLUME_PERC - it is a volume of the third order in percentage
* SELL_ORDER_DISTANCE - distance of average sell price
* MM_BUY_ORDER_PERC - money-management volume of first buy order in percentage