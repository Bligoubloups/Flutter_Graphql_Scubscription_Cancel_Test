import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client;
WebSocketLink webSocketLink;
void main() {
  final HttpLink httpLink = HttpLink(
    'http://192.168.1.11:6001/graphql',
  );

  webSocketLink = WebSocketLink(
    'ws://192.168.1.11:6001/graphql',
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
  bool _shouldRenderSub;

  @override
  void initState() {
    super.initState();
    _shouldRenderSub = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldRenderSub == false) {
      webSocketLink.dispose();
    }
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
                      _shouldRenderSub = !_shouldRenderSub;
                    });
                  },
                  child: _shouldRenderSub
                      ? Text("Unsubscribe")
                      : Text("Subscribe"),
                ),
              ),
              if (_shouldRenderSub) SubscribeWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscribeWidget extends StatelessWidget {
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
