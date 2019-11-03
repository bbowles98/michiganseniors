# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import JsonResponse

from rest_framework.generics import RetrieveAPIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework import filters
from django.db import connection

from django.contrib.auth.models import User
from elect_api.models import Election, BallotItem, BallotItemChoice

import random


# Returns all election data of elections that contain the search string, ignoring case
@api_view(['GET'])
@permission_classes((AllowAny, ))
def SearchViewSet(request):

	electionName = request.GET.get('name')
	elections = Election.objects.filter(name__icontains=electionName)
	response = []
	for election in elections:
		electionDict = {}
		electionDict['name'] = election.name
		electionDict['creator'] = election.creator.username
		electionDict['passcode'] = election.passcode
		electionDict['status'] = election.status
		response.append(electionDict)

	return JsonResponse({'election': response})


# Get results for election based on an election id
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewResults(request):

	return JsonResponse({'results':[10, 9, 8]})


# POST request for registering for an election
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Register(request):

	return JsonResponse({'success': True})


# POST request for submitting a vote for an election
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Vote(request):

	return JsonResponse({'success': True})


# POST request for creating an election
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def CreateElection(request):

	user = User.objects.get(pk=request.user.pk)

	if not user:
		return JsonResponse({'success': False})

	passcode = random.randint(100000, 999999)

	new_election = Election.objects.create(
		name=request.data['name'],
		creator=user,
		passcode=passcode,
		status=False
	)

	if not new_election:
		return JsonResponse({'success': False})

	# Do we need to .save() the election to the database?

	return JsonResponse({'election_id': new_election.pk, 'passcode': passcode, 'success': True})


# POST request for creating a ballot for a given election
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def CreateBallot(request):

	user = User.objects.get(pk=request.user.pk)
	if not user:
		return JsonResponse({'success': False})

	election = Election.objects.get(pk=request.data['election_id'])
	if not election or election.creator != user:
		return JsonResponse({'success': False})

	for ballot_item in request.data['ballot_items']:

		new_ballot_item = BallotItem.objects.create(
			election=election,
			question=ballot_item['question']
		)

		if not new_ballot_item:
			return JsonResponse({'success': False})

		for ballot_item_choice in ballot_item['choices']:

			new_ballot_item_choice = BallotItemChoice.objects.create(
				ballot_item = new_ballot_item,
				answer=ballot_item_choice
			)

			if not new_ballot_item_choice:
				return JsonResponse({'success': False})

	# Do we need to .save() the ballot and ballot choices to the database?

	return JsonResponse({'success': True})


# POST request for changing the activity status of an election
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def GoLive(request):

	user = User.objects.get(pk=request.user.pk)
	if not user:
		return JsonResponse({'success': False})

	election = Election.objects.get(pk=request.data['election_id'])
	if not election or election.creator != user:
		return JsonResponse({'success': False})

	if request.data['active']:
		
		ballot_items = BallotItem.objects.filter(election=election)
		if len(ballot_items) > 0:
			election.status = True
			election.save()

			return JsonResponse({'success': True, 'live': True})

	election.status = False
	election.save()

	return JsonResponse({'success': True, 'live': False})
