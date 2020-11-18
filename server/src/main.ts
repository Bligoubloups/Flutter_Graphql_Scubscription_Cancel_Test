import { ApolloServer, gql } from "apollo-server";
import { PubSub } from "apollo-server";

const pubsub = new PubSub();

const typeDefs = gql`
  type Subscription {
    value: Int
  }
  type Query {
    weDontCare_need_for_root: Int
  }
`;

const resolvers = {
  Subscription: {
    value: {
      subscribe: () => pubsub.asyncIterator(["SUB"]),
    },
  },
  Query: {
    weDontCare_need_for_root() {
      return 1;
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
