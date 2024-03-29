﻿//+------------------------------------------------------------------+
//|                                                   SIMPLE BOT.mq4 |
//|                                                      Ivan Petrov |
//+------------------------------------------------------------------+
#property copyright "Ivan Petrov"
#property link      "cryptokot.ru"
#property version   "1.00"
#property strict
//--- input parameters
input double   BasePrft = 685.0;
input double   BaseLoss = 769.0;
bool           FullAuto = true;

extern double  risk = 1.0;
extern int     totl = 10;
double         lots = 0.1;
extern int     bars = 2;
extern int     bid1 = 13;
extern int     bid2 = 28;
extern int     ask1 = 78;
extern int     ask2 = 98;
extern double  diff = 39;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double mainFractals1 = iFractals(NULL, PERIOD_M1, MODE_UPPER, 2);
   double mainFractals2 = iFractals(NULL, PERIOD_M1, MODE_LOWER, 2);
   double smallRSI      = iRSI(NULL, PERIOD_D1, bars, PRICE_CLOSE, 1);

   int magic = 10000 + Day() * 3600 + Hour()*60 + Minute();
   if(FullAuto)
     {
      lots = AccountBalance() / 100000 * risk;
      if (lots < 0.01) {
         lots = 0.01;      // Рекомендуется депозит не менее 1000 единиц во избежание повышения риска
      }
      if (lots > 999.99) {
         lots = 999.99;    // Максимально возможный лот на большинстве брокеров
      }
     }
   if(mainFractals2 != 0)  // Если образовался фрактал снизу
     {
      double mode       = MarketInfo(Symbol(),MODE_BID);
      double price      = Bid;
      double stoploss   = NormalizeDouble(Bid - BaseLoss * Point, Digits);
      double takeprofit = NormalizeDouble(Ask + BasePrft * Point, Digits);
      if((!restricted()) && betterBid() && OrdersTotal() < totl) 
      // Если не запрещено открывать ордер, если это лучшая из возможных покупок и ордеров открыто не слишком много
        {
         if(smallRSI >= bid1 && smallRSI <= bid2) // Если индекс RSI в диапазоне покупки
           {
            RefreshRates();
            int ticket = OrderSend(Symbol(), OP_BUY, lots, Bid, MODE_SPREAD + 1, stoploss, takeprofit, "", magic, 0, clrGold);
           }
        }
     }
   if(mainFractals1 != 0)  // Если образовался фрактал сверху
     {
      double mode       = MarketInfo(Symbol(),MODE_ASK);
      double price      = Ask;
      double stoploss   = NormalizeDouble(Ask + BaseLoss * Point, Digits);
      double takeprofit = NormalizeDouble(Bid - BasePrft * Point, Digits);
      if((!restricted()) && betterAsk() && OrdersTotal() < totl) 
      // Если не запрещено открывать ордер, если это лучшая из возможных продаж и ордеров открыто не слишком много
        {
         if(smallRSI >= ask1 && smallRSI <= ask2) // Если индекс RSI в диапазоне продажи
           {
            RefreshRates();
            int ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, MODE_SPREAD + 1, stoploss, takeprofit, "", magic, 0, clrGold);
           }
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool restricted()
  {
   double magic = 10000 + Day() * 3600 + Hour()*60 + Minute();
   int orders = 0;
   for(orders = OrdersTotal() - 1; orders >= 0; orders--)
     {
      int order = OrderSelect(orders, SELECT_BY_POS, MODE_TRADES);
      if((OrderSymbol() == Symbol() && OrderMagicNumber() == magic))
        {
         return true;
        }
      if(DayOfWeek() == 5) // В пятницу не торгуем, закрываем старые ордера.
        {
         return true; 
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool betterBid()
  {
   int orders = 0;
   for(orders = OrdersTotal() - 1; orders >= 0; orders--)
     {
      int order = OrderSelect(orders, SELECT_BY_POS, MODE_TRADES);
      if((OrderType() == OP_BUY && Bid > (OrderOpenPrice() + diff * Point)))
        {
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool betterAsk()
  {
   int orders = 0;
   for(orders = OrdersTotal() - 1; orders >= 0; orders--)
     {
      int order = OrderSelect(orders, SELECT_BY_POS, MODE_TRADES);
      if((OrderType() == OP_SELL && Ask < (OrderOpenPrice() - diff * Point)))
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
