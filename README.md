# Run the project

### Run the server

`cd server`  
`npm i`  
`npm run dev`

### Run the Flutter app

Put your `ip address` in the `httpLink` and in the `webSocketLink`  
`flutter pub get`  
`flutter run`

### Problem

In the logs of nodejs, you ll see CONNECTED but never DISCONNECTED.

To create the Subscription, simply clic on Subscribe.  
To unmount it, clic on Unsubscribe


### Solution

Solution on the branch solution.
But not sure if its the right way to do it.

### Do not close websockets manually

Instead of closing the websocket, flutter-graphql actually closes the subscription.
We handle what happens in backend when a subscription is closed in the branch: closing-subscription-only
