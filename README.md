# rabbitmq_showcase
A little Rails app to consume and display messages from a running RabbitMQ message broker.
For further explanation, see the [blog posts here](http://alihuber.github.io/rabbitmq) and the corresponding Java program: [RabbitMQTestdriver](https://github.com/alihuber/RabbitMQTestdriver).


## Setup
Standard Rails: Clone the repo, `bundle install`, configure your database etc.
## Features
Displayed features of RabbitMQ correspond to menu entries in the app. The app implements various messaging scenarios, partly taken from the official [RabbitMQ tutorial](https://www.rabbitmq.com/getstarted.html). First simple functionalities are implemented using the [Bunny](http://www.rubybunny.info) gem, workflows are incorporated using [Sneakers.io](http://github.com/jondot/sneakers). All the app does is consuming incoming messages (with or without delay) and persisting them into the database. Inserted records are displayed in tables on their corresponding page. The contents of the tables refresh themselves in case you flooded the system with ten thousands of messages. By clicking on "Delete Records" on each page all messages regarding this particular showcase are wiped from the database.
### Smoke test
![settings.png](http://alihuber.github.io/images/smoke_rails.png)

Self-explanatory. Note that only messages sent to the queue named "default" will show up, all others will pile up in the broker.

### Topics
![settings.png](http://alihuber.github.io/images/topic_rails.png)

This page features three tables to display messages that were sent to the topic exchange "log". The hints on the page indicate that there are three different listeners for messages that are equipped with certain routing keys. In the somewhat contrived 'logging' scenario you can deliver messages to only one ore multiple queues at once by entering the correct routing key in the corresponding Java program.

### Worker queue
![settings.png](http://alihuber.github.io/images/worker_rails.png)

Functionality shown on this page maps more or less directly to the [work queue example](https://www.rabbitmq.com/tutorials/tutorial-two-java.html) of the RabbitMQ tutorial. The message will be consumed by the Rails app after the given amount of seconds.

### Workflow
![settings.png](http://alihuber.github.io/images/workflow_rails.png)

Like stated on the hint, the Rails app uses [Sneakers.io](https://github.com/jondot/sneakers.io) to simulate interdependent workflows and re-enqueuing of failed messages. The message text will show up in the Rails app only if it has been acknowledged by the first and second Sneakers.io worker. To make things more fun, the messages will be delayed, rejected 1/10th of the time and re-enqueued automatically, which is observed best by flooding the queues with hundreds of random messages.
