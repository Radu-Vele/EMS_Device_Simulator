import pika
import os
import sys

message_queue_name = os.getenv('MESSAGE_QUEUE_NAME')

connection_params = pika.URLParameters(os.getenv('CLOUD_AMQP_URL'))

# Connect to the RabbitMQ server
connection = pika.BlockingConnection(connection_params)
channel = connection.channel()

# Declare a queue
channel.queue_declare(queue=message_queue_name, durable=True)

# Publish a message to the queue
channel.basic_publish(exchange='',
                      routing_key=message_queue_name,
                      body=sys.argv[1])

print(" [x] Sent " + sys.argv[1])

# Close the connection
connection.close()
