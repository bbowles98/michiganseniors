# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from rest_framework.generics import RetrieveAPIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework import filters
from django.db import connection

from django.contrib.auth.models import User
from elect_api.models import Election, BallotItem, BallotItemChoice
from elect_api.serializers import UserSerializer

import random


# Returns all election data of elections that contain the search string, ignoring case
@csrf_exempt
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
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewResults(request):

	return JsonResponse({'results':[10, 9, 8]})


# POST request for registering for an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Register(request):

	return JsonResponse({'success': True})


# POST request for submitting a vote for an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Cast(request):

	# Implement corda vote in blockchain

	return JsonResponse({'success': True})


# GET request for viewing the ballot of an election, work in progress
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def Vote(request):

	code = request.GET.get('code')
	try:
		election = Election.objects.filter(passcode=code)[0]
		if (election.status == False):
			return JsonResponse({"status": "This election is not live yet"})

		ballot_items = BallotItem.objects.filter(election=election)
		response = []
		for ballot_item in ballot_items:
			ballot = {}
			ballot_item_choices = BallotItemChoice.objects.filter(ballot_item=ballot_item)
			choices = []
			for ballot_item_choice in ballot_item_choices:
				choices.append(ballot_item_choice.answer)
			ballot[ballot_item.question] = choices
			response.append(ballot)
		return JsonResponse({"ballot": response})

	except:
		return JsonResponse({"status": "This election does not exist"})



# POST request for creating an election
@csrf_exempt
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

	return JsonResponse({'election_id': new_election.pk, 'passcode': passcode, 'success': True})


# POST request for creating a ballot for a given election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def CreateBallot(request):

	user = User.objects.get(pk=request.user.pk)
	if not user:
		return JsonResponse({'success': False})

	election = Election.objects.filter(passcode=request.data['election_id'])[0]
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

	return JsonResponse({'success': True})


# POST request for changing the activity status of an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def GoLive(request):

	user = User.objects.get(pk=request.user.pk)
	if not user:
		return JsonResponse({'success': False})

	election = Election.objects.filter(passcode=request.data['election_id'])[0]
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


# Returns all elections that a host has made
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewElections(request):

	user = User.objects.get(pk=request.user.pk)
	if not user:
		return JsonResponse({'success': False})

	elections = Election.objects.filter(creator=user)
	response = []
	for election in elections:
		electionDict = {}
		electionDict['name'] = election.name
		electionDict['creator'] = election.creator.username
		electionDict['passcode'] = election.passcode
		electionDict['status'] = election.status
		response.append(electionDict)

	return JsonResponse({'election': response})

@csrf_exempt
@api_view(['POST'])
@permission_classes((AllowAny,))
def CreateAccount(request):

	if request.method != 'POST':
		return JsonResponse({})

	serializer = UserSerializer(data=request.data)
	if serializer.is_valid():
		user = serializer.save()
		if user:
			return JsonResponse(serializer.data)

	return JsonResponse(serializer.errors)


