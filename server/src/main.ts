import { ApolloServer, gql } from "apollo-server";
import { PubSub } from "apollo-server";

const pubsub = new PubSub();

let number = 1;

const typeDefs = gql`
  type Subscription {
    value: Int
  }
  type Query {
    publishQuery: Int
  }
`;

function withCancel<T>(
  asyncIterator: AsyncIterator<T | undefined>,
  onCancel: () => void
) {
  let saved_return = asyncIterator.return;

  asyncIterator.return = () => {
    onCancel();
    return saved_return
      ? saved_return.call(asyncIterator)
      : Promise.resolve({ value: undefined, done: true });
  };

  return asyncIterator;
}

const resolvers = {
  Subscription: {
    value: {
      subscribe: () =>
        withCancel(pubsub.asyncIterator("SUB"), () => {
          console.log(`Subscription closed, do your cleanup`);
        }),
      // subscribe: () => pubsub.asyncIterator("SUB"),
    },
  },
  Query: {
    publishQuery() {
      pubsub.publish("SUB", { value: number++ });
      return number;
    },
  },
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
  playground: true,
  introspection: true,
  context: ({ req }) => req,
  subscriptions: {
    keepAlive: 10000,
    onConnect: (_, __) => {
      console.log("CONNECTED"); // This is called
    },
    onDisconnect: (_, __) => {
      console.log("DISCONNECTED"); // This is never called (Only if you close the app)
    },
  },
});

// The `listen` method launches a web server.
server.listen({ port: 6001 }).then(({ url, subscriptionsUrl }) => {
  console.log(`Server ready at ${url}`);
  console.log(`Subscriptions ready at ${subscriptionsUrl}`);
});
