# -*- coding: utf-8 -*-
# Generated by Django 1.11.23 on 2019-12-02 00:11
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('elect_api', '0007_auto_20191202_0003'),
    ]

    operations = [
        migrations.RenameField(
            model_name='election',
            old_name='max_users',
            new_name='max_voters',
        ),
    ]
