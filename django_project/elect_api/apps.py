# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.apps import AppConfig
from apscheduler.schedulers.background import BackgroundScheduler
import sys, socket


class ElectApiConfig(AppConfig):
    name = 'elect_api'


    def ready(self):

		try:
			sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			sock.bind(("127.0.0.1", 47200))
		except socket.error:
			print "!!!scheduler already started, DO NOTHING"
		else:
			from elect_api.views import send_vote_reminder
			scheduler = BackgroundScheduler()
			scheduler.add_job(send_vote_reminder, 'cron', hour=12, minute=0)
			scheduler.start()