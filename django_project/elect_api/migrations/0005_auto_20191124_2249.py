# -*- coding: utf-8 -*-
# Generated by Django 1.11.23 on 2019-11-24 22:49
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('elect_api', '0004_auto_20191108_1646'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='voteobject',
            name='election',
        ),
        migrations.DeleteModel(
            name='VoteObject',
        ),
    ]
