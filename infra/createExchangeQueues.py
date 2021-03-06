#!/usr/bin/env python3
import os
import sys

import pika

USER = "user"
PASSWORD = "local-password"
HOST = "localhost"

QUEUE = "user_management"
USER_MANAGEMENT_ROUTING_KEY = "jobportal.user.*.events"

POSTINGS_MANAGEMENT_ROUTING_KEY = "jobportal.postings.*.events"
LOGGING_EXCHANGE = "logging"

credentials = pika.PlainCredentials(USER, PASSWORD)
parameters = pika.ConnectionParameters(HOST, 5672, '/', credentials)

print(f'Connecting to RabbitMQ host: {HOST}:5672 with user: {USER}')
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

channel.exchange_declare(exchange=LOGGING_EXCHANGE, exchange_type='topic', durable=True)
print(f'Exchange: {LOGGING_EXCHANGE} created')
channel.queue_declare(queue=QUEUE, exclusive=False, durable=True)
print(f'Queue: {QUEUE} created')

channel.queue_bind(QUEUE, LOGGING_EXCHANGE, routing_key=USER_MANAGEMENT_ROUTING_KEY)
print(f'Queue: {QUEUE} binded to exchange: {LOGGING_EXCHANGE} via routing key: {USER_MANAGEMENT_ROUTING_KEY}')
channel.queue_bind(QUEUE, LOGGING_EXCHANGE, routing_key=POSTINGS_MANAGEMENT_ROUTING_KEY)
print(f'Queue: {QUEUE} binded to exchange: {LOGGING_EXCHANGE} via routing key: {POSTINGS_MANAGEMENT_ROUTING_KEY}')
print(f'Setup finished!')

connection.close()