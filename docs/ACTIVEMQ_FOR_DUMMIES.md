# ActiveMQ for Dummies

## What is ActiveMQ?
Apache ActiveMQ is an open-source message broker that enables applications to communicate with each other using messaging protocols. It is widely used for building distributed systems, microservices, and event-driven architectures.

## Why Use ActiveMQ?
- Decouples producers and consumers
- Reliable message delivery
- Supports multiple protocols (OpenWire, AMQP, MQTT, STOMP, WebSocket)
- Easy to scale and integrate

## Basic Concepts
- **Broker**: The server that manages message queues and topics
- **Queue**: Point-to-point messaging (one consumer per message)
- **Topic**: Publish/subscribe messaging (multiple consumers per message)
- **Producer**: Sends messages
- **Consumer**: Receives messages

## Quick Start

### 1. Start ActiveMQ with Docker Compose
```sh
zsh scripts/start.sh
```

### 2. Access the Web Console
- URL: [http://localhost:8161/admin](http://localhost:8161/admin)
- Default user: `admin`
- Default password: `admin`

### 3. Send and Receive Messages
- Use the web console to create queues and topics
- Send test messages from the console
- Connect your applications using supported protocols

## Example: Sending a Message (Java)
```java
import javax.jms.*;
import org.apache.activemq.ActiveMQConnectionFactory;

public class SimpleProducer {
    public static void main(String[] args) throws Exception {
        ConnectionFactory factory = new ActiveMQConnectionFactory("tcp://localhost:61616");
        Connection connection = factory.createConnection();
        connection.start();
        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        Destination queue = session.createQueue("test.queue");
        MessageProducer producer = session.createProducer(queue);
        TextMessage message = session.createTextMessage("Hello, ActiveMQ!");
        producer.send(message);
        session.close();
        connection.close();
    }
}
```

## Example: Receiving a Message (Java)
```java
import javax.jms.*;
import org.apache.activemq.ActiveMQConnectionFactory;

public class SimpleConsumer {
    public static void main(String[] args) throws Exception {
        ConnectionFactory factory = new ActiveMQConnectionFactory("tcp://localhost:61616");
        Connection connection = factory.createConnection();
        connection.start();
        Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
        Destination queue = session.createQueue("test.queue");
        MessageConsumer consumer = session.createConsumer(queue);
        Message message = consumer.receive(1000);
        if (message instanceof TextMessage) {
            System.out.println(((TextMessage) message).getText());
        }
        session.close();
        connection.close();
    }
}
```

## Useful Docker Commands
- Start: `zsh scripts/start.sh`
- Stop: `docker compose -f docker/docker-compose.yml down`
- Logs: `docker compose -f docker/docker-compose.yml logs -f activemq`
- Exec: `docker compose -f docker/docker-compose.yml exec activemq bash`

## Troubleshooting
- Check container logs for errors
- Make sure ports are not blocked by firewall
- Change default credentials for production

## Resources
- [ActiveMQ Documentation](https://activemq.apache.org/components/classic/)
- [Docker Hub - ActiveMQ](https://hub.docker.com/r/apache/activemq-classic)
- [JMS Tutorial](https://www.oracle.com/java/technologies/java-message-service.html)

---

*This guide is for beginners. For advanced usage, refer to the official documentation.*
