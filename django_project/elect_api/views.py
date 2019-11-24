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
from datetime import datetime
from django.contrib.auth.models import User
from elect_api.models import Election, BallotItem, BallotItemChoice, VoteObject, VoterToElection, RegisterLink
from elect_api.serializers import UserSerializer
from elect_api.gmail import sendMail

import random, requests

DEBUG = True


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
		electionDict['election_id'] = election.pk
		electionDict['start_date'] = election.start_date
		electionDict['end_date'] = election.end_date
		response.append(electionDict)

	return JsonResponse({'election': response})



# Get results for election based on an election id
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewResults(request):

	election = Election.objects.get(pk=request.GET.get('election_id'))
	votes = VoteObject.objects.filter(election=election)
	candidates_to_counts = {}
	for vote in votes:
		if vote.answer not in candidates_to_counts:
			candidates_to_counts[vote.answer] = 0
		candidates_to_counts[vote.answer] += 1
	response = {}
	response['ballot'] = {}
	for candidate, ans in candidates_to_counts.iteritems():
		response['ballot'][candidate] = ans
	response['name'] = election.name
	response['total_votes'] = len(votes)

	live = isElectionLive(election)
	response['live'] = live

	return JsonResponse({'results': response})


# POST request for registering for an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Register(request):

	user = User.objects.get(pk=request.user.pk)
	election = Election.objects.get(pk=request.data['election_id'])
	passcode = request.data['passcode']

	if passcode != election.passcode:
		return JsonResponse({'error': 'incorrect passcode'})

	registeredUser = RegisterLink.objects.create(
			election = election,
			participant = user
		)
	msg = "Subject: You're Registered!\n\nYou have been successfully registered for " + election.name
	sendMail(user.email, msg)
	return JsonResponse({'success': True})


# POST request for submitting a vote for an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Cast(request):

	user = User.objects.get(pk=request.user.pk)
	election = Election.objects.get(pk=request.data['election_id'])
	ballot_items = BallotItem.objects.filter(election=election)
	answer = request.data['candidate']

	json = canUserVote(user, election)
	if json:
		return json

	valid_candidate = False
	for ballot_item in ballot_items:
		ballot_item_choices = BallotItemChoice.objects.filter(ballot_item=ballot_item)
		for ballot_item_choice in ballot_item_choices:
			if ballot_item_choice.answer == answer:
				valid_candidate = True
	if not valid_candidate:
		return JsonResponse({"error": "invalid candidate"})

	# vote_corda_url = "http://206.81.10.10:10050/put"

	# data = {


	# }

	# response = requests.post(url=vote_corda_url, data=data)


	new_vote = VoteObject.objects.create(
			election = election,
			answer = answer
		)

	if not new_vote:
		return JsonResponse({'success': False})

	user_voted = VoterToElection.objects.create(
			election = election,
			voter = user
		)

	msg = "Subject: You've Voted!\n\nYou have been successfully voted in " + election.name
	sendMail(user.email, msg)

	return JsonResponse({'success': True})


# GET request for viewing the ballot of an election, work in progress
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def Vote(request):

	user = User.objects.get(pk=request.user.pk)
	election = Election.objects.get(pk=request.data['election_id'])

	json = canUserVote(user, election)
	if json:
		return json

	if (election.status == False and not DEBUG):
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
		status=True,
		start_date=request.data['start_date'],
		end_date=request.data['end_date']
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

	return JsonResponse({'success': True})


# POST request for changing the activity status of an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def GoLive(request):

	user = User.objects.get(pk=request.user.pk)
	if not user:
		return JsonResponse({'success': False})

	election = Election.objects.get(pk=request.data['election_id'])
	if not election or election.creator != user:
		return JsonResponse({'success': False})

	election.status = (request.data['live'] == "true")
	election.save()

	return JsonResponse({'success': True, 'live': True})


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
		electionDict['election_id'] = election.pk
		electionDict['start_date'] = election.start_date
		electionDict['end_date'] = election.end_date
		response.append(electionDict)

	return JsonResponse({'election': response})

# Returns all elections that a user is registered in
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewRegisteredElections(request):

	user = User.objects.get(pk=request.user.pk)
	registered = RegisterLink.objects.filter(participant=user)
	response = []
	for register in registered:
		response.append(register.election.pk)
	
	return JsonResponse({"elections": response})

# Returns all elections that a user has voted in
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewPastElectionsUserVotedIn(request):

	user = User.objects.get(pk=request.user.pk)
	registered = VoterToElection.objects.filter(voter=user)
	response = []
	for register in registered:
		response.append(register.election.pk)
	
	return JsonResponse({"elections": response})

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

@csrf_exempt
@api_view(['DELETE'])
@permission_classes((IsAuthenticated,))
def DeleteElection(request):

	election = Election.objects.get(pk=request.data['election_id'])
	election.delete()

	return JsonResponse({"status": "deleted"})

@csrf_exempt
@api_view(['DELETE'])
@permission_classes((IsAuthenticated,))
def DeleteAllElections(request):

	elections = Election.objects.all()
	for election in elections:
		election.delete()

	return JsonResponse({"status": "deleted"})

@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated,))
def CanViewElectionResults(request, election_id):

	can_view = False

	try:
		election = Election.objects.get(pk=election_id)
		user_elections = VoterToElection.objects.filter(election=election, user=request.user)
		can_view = len(user_elections) == 0

	except:
		return Json({'can_view': False})

	return Json({'can_view': can_view})


def canUserVote(user, election):

	if DEBUG:
		return

	time = datetime.now()
	if time < datetime.strptime(election.start_date, '%Y-%m-%d %H:%M:%S') or time > datetime.strptime(election.end_date, '%Y-%m-%d %H:%M:%S'):
		return JsonResponse({'error': 'This election is not live yet'})

	try:
		is_user_registered = RegisterLink.objects.filter(election=election)
		is_user_registered = is_user_registered.filter(participant=user)[0]
	except:
		return JsonResponse({'error': 'This user is not resisted in this election'})

	try:
		didUserVote = VoterToElection.objects.filter(voter=user)
		didUserVote = didUserVote.filter(election=election)[0]
		return JsonResponse({"error": "This user has already voted in this election!"})
	except:
		pass

def isElectionLive(election):
	if election.start_date == '':
		return False

	time = datetime.now()
	if time < datetime.strptime(election.start_date, '%Y-%m-%d %H:%M:%S') or time > datetime.strptime(election.end_date, '%Y-%m-%d %H:%M:%S'):
		return False
	return True



