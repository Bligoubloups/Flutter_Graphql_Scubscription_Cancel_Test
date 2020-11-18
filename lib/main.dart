import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client;
void main() {
  final HttpLink httpLink = HttpLink(
    'http://YOUR_IP_ADDRESS:6001/graphql',
  );

  final WebSocketLink webSocketLink = WebSocketLink(
    'ws://YOUR_IP_ADDRESS:6001/graphql',
    config: SocketClientConfig(
      initialPayload: () async => <dynamic, dynamic>{
        "connectionParams": {
          "authorization": true,
        }
      },
    ),
  );

  Link link = httpLink;
  link = Link.split((request) => request.isSubscription, webSocketLink, link);

  client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    ),
  );
  runApp(Main());
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  bool shouldRenderSub;

  @override
  void initState() {
    super.initState();
    shouldRenderSub = false;
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Cancel Subscription Test'),
          ),
          body: Column(
            children: [
              Center(
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      shouldRenderSub = !shouldRenderSub;
                    });
                  },
                  child:
                      shouldRenderSub ? Text("Unsubscribe") : Text("Subscribe"),
                ),
              ),
              if (shouldRenderSub) SubscribeWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscribeWidget extends StatelessWidget {
  const SubscribeWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Subscription(
        options: SubscriptionOptions(
          document: gql(r'''
          subscription subscribe {
            value
          }
          '''),
          variables: null,
        ),
        builder: (result) {
          if (result.isLoading) {
            return const CircularProgressIndicator();
          }
          return Text("We dont care about that");
        },
      ),
    );
  }
}
