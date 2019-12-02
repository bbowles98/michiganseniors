# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models
from django.contrib.auth.models import User


class Election(models.Model):

	name = models.CharField(max_length=100, default="")
	creator = models.ForeignKey(User, on_delete=models.CASCADE)
	passcode = models.CharField(max_length=6, default="")
	status = models.BooleanField(default=False)
	start_date = models.CharField(max_length=40, default="")
	end_date = models.CharField(max_length=40, default="")
	message = models.CharField(max_length=100, default="")

class BallotItem(models.Model):

	election = models.ForeignKey(Election, on_delete=models.CASCADE)
	question = models.CharField(max_length=500, default="")


class BallotItemChoice(models.Model):

	ballot_item = models.ForeignKey(BallotItem, on_delete=models.CASCADE)
	answer = models.CharField(max_length=500, default="")


class RegisterLink(models.Model):

	election = models.ForeignKey(Election, on_delete=models.CASCADE)
	participant = models.ForeignKey(User, on_delete=models.CASCADE)


class VoterToElection(models.Model):

	election = models.ForeignKey(Election, on_delete=models.CASCADE)
	voter = models.ForeignKey(User, on_delete=models.CASCADE)

class ElectionKey(models.Model):

	election = models.ForeignKey(Election, on_delete=models.CASCADE)
	key = models.CharField(max_length=6, default="")
