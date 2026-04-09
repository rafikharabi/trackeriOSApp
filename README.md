# Real-Time Stock Price Tracker

A production-ready iOS application that tracks real-time stock prices
using WebSocket connections, built with **Clean Architecture** and
**MVVM pattern**.

------------------------------------------------------------------------

## Overview

This application demonstrates a real-time stock tracking system that
connects to a WebSocket server to receive live price updates.

It features: - 25 pre-loaded stock symbols\
- Real-time price updates\
- Sorting capabilities\
- Detailed stock view

Built using industry best practices: - Clean Architecture\
- MVVM Pattern\
- SOLID Principles\
- Unit Testing

------------------------------------------------------------------------

## Features

-   **Real-time Stock Updates** via WebSocket\
-   **25 Stock Symbols** (AAPL, GOOGL, TSLA, AMZN, MSFT, NVDA, etc.)\
-   **Sorting Options** (symbol, price, percentage change)\
-   **Connection Control** (start/stop with status indicator)\
-   **Detail Screen** with company info\
-   **Visual Indicators** (green ↑, red ↓)\
-   **Responsive UI** for all iPhones

------------------------------------------------------------------------

## Architecture

Clean Architecture + MVVM pattern with Presentation, Domain, and Data
layers.

------------------------------------------------------------------------

## Requirements

-   Xcode 14+\
-   iOS 16+\
-   Swift 5.7+

------------------------------------------------------------------------

## Installation

``` bash
git clone https://github.com/yourusername/RealTimeStockTracker.git
cd RealTimeStockTracker
open RealTimeStockTracker.xcodeproj
```

------------------------------------------------------------------------

## WebSocket

-   Endpoint: wss://ws.postman-echo.com/raw\
-   Updates every 2 seconds

------------------------------------------------------------------------

## Testing

Run tests using:

``` bash
xcodebuild test -scheme RealTimeStockTracker
```

------------------------------------------------------------------------

## Conclusion

A scalable, testable iOS app demonstrating real-time updates using
modern Swift.
