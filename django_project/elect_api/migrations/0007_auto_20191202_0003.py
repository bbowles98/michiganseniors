# -*- coding: utf-8 -*-
# Generated by Django 1.11.23 on 2019-12-02 00:03
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('elect_api', '0006_election_message'),
    ]

    operations = [
        migrations.AddField(
            model_name='election',
            name='email_domain',
            field=models.CharField(default='', max_length=100),
        ),
        migrations.AddField(
            model_name='election',
            name='max_users',
            field=models.IntegerField(default=0),
        ),
    ]
