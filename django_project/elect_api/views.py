# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from rest_framework.generics import RetrieveAPIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework.response import Response
from rest_framework import filters
from django.db import connection
from datetime import datetime
from django.contrib.auth.models import User
from elect_api.models import Election, BallotItem, BallotItemChoice, VoterToElection, RegisterLink, ElectionKey
from elect_api.serializers import UserSerializer
from elect_api.gmail import sendMail

import random, requests

DEBUG = True


# Returns all election data of elections that contain the search string, ignoring case
@csrf_exempt
@api_view(['GET'])
@permission_classes((AllowAny, ))
def SearchViewSet(request):

	try:
		electionName = request.GET.get('name')
		elections = Election.objects.filter(name__icontains=electionName)
	except:
		election = Election.objects.all()

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
		electionDict['max_voters'] = election.max_voters
		electionDict['email_domain'] = election.email_domain
		response.append(electionDict)

	return JsonResponse({'election': response})



# Get results for election based on an election id
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewResults(request):

	try:
		election = Election.objects.get(pk=request.GET.get('election_id'))
	except:
		return JsonResponse({'error': 'Election not found, make sure election_id is sent correctly.'})

	results_corda_url = "http://206.81.10.10:10050/votes"

	try:
		response = requests.get(results_corda_url)
		data = response.json()
	except:
		return JsonResponse({'error': 'Corda API connection error'})

	votes = 0
	candidates_to_counts = {}

	for vote in data:
		if vote['state']['data']['electionID'] == election.pk:
			if vote['state']['data']['selection'] not in candidates_to_counts:
				candidates_to_counts[vote['state']['data']['selection']] = 0
			candidates_to_counts[vote['state']['data']['selection']] += 1
			votes += 1

	results = {}
	results['ballot'] = {}
	results['candidates'] = []
	results['votes'] = []
	for candidate, ans in candidates_to_counts.iteritems():
		results['ballot'][candidate] = ans
		results['candidates'].append(candidate)
		results['votes'].append(ans)
	results['name'] = election.name
	results['total_votes'] = votes

	live = isElectionLive(election)
	results['live'] = live

	return JsonResponse({'results': results})


# POST request for registering for an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Register(request):

	user = User.objects.get(pk=request.user.pk)

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	registration_check = RegisterLink.objects.filter(election=election, participant=user)
	if len(registration_check) != 0:
		return JsonResponse({'success': False, 'error': 'User has already registered in this election'})

	try:
		passcode = request.data['passcode']
	except:
		return JsonResponse({'success': False, 'error': 'Make sure to send passcode in JSON data'})

	keys = ElectionKey.objects.filter(election=election)
	list_of_keys = []
	for key in keys:
		list_of_keys.append(key.key)
	if passcode != election.passcode and passcode not in list_of_keys:
		return JsonResponse({'success': False, 'error': 'Invalid passcode'})

	if passcode in list_of_keys:
		key = keys.get(key=passcode)
		key.delete()

	if election.max_voters > 0:
		num_registered = len(RegisterLink.objects.filter(election=election))
		if num_registered >= election.max_voters:
			return JsonResponse({'success': False, 'error': 'Max number of voters has been reached'})

	if election.email_domain != "":
		if election.email_domain not in request.user.email:
			return JsonResponse({'success': False, 'error': 'User cannot register for election because of email restrictions'})


	registeredUser = RegisterLink.objects.create(
			election = election,
			participant = user
		)

	msg = "Subject: You're Registered!\n\nYou have been successfully registered for " + election.name
	sendMail(user.email, msg)

	return JsonResponse({'success': True})


# POST request for registering for an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def PublicRegister(request):

	user = User.objects.get(pk=request.user.pk)

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	if election.max_voters > 0:
		num_registered = len(RegisterLink.objects.filter(election=election))
		if num_registered >= election.max_voters:
			return JsonResponse({'success': False, 'error': 'Max number of voters has been reached'})

	if election.email_domain != "":
		if election.email_domain not in request.user.email:
			return JsonResponse({'success': False, 'error': 'User cannot register for election because of email restrictions'})

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

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	ballot_items = BallotItem.objects.filter(election=election)

	if not ballot_items:
		return JsonResponse({'success': False, 'error': 'No ballot items found for this election'})

	try:
		answer = request.data['candidate']
	except:
		return JsonResponse({'success': False, 'error': 'Candidate choice not sent'})

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
		return JsonResponse({'success': False, "error": "invalid candidate"})

	issue_val = 0
	election_id = election.pk
	selection_val = answer

	headers = {
		'Content-Type': 'application/x-www-form-urlencoded'
	}

	vote_corda_url = "http://206.81.10.10:10050/put?electionVal=O=Host0,L=London,C=GB&voter=O=Voter,L=NewYork,C=US"
	vote_corda_url += "&issueVal=" + str(issue_val)
	vote_corda_url += "&selectionVal=" + str(selection_val)
	vote_corda_url += "&electionID=" + str(election_id)

	data = {}

	try:
		response = requests.post(url=vote_corda_url, data=data, headers=headers)

	except:
		return JsonResponse({'success': False, 'error': 'Corda API error while voting'})

	voter_to_election = VoterToElection.objects.create(election=election, voter=user)

	msg = "Subject: You've Voted!\n\nYou have been successfully voted in " + election.name
	sendMail(user.email, msg)

	return JsonResponse({'success': True})


# GET request for viewing the ballot of an election, work in progress
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def Vote(request):

	user = User.objects.get(pk=request.user.pk)

	try:
		election = Election.objects.get(pk=request.GET.get('election_id'))
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	json = canUserVote(user, election)
	if json:
		return json

	if (election.status == False and not DEBUG):
	 	return JsonResponse({'success': False, "error": "This election is not live yet"})

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
	return JsonResponse({"ballot": response, 'is_light': election.message})



# POST request for creating an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def CreateElection(request):

	user = User.objects.get(pk=request.user.pk)

	passcode = random.randint(100000, 999999)
	message = ""

	if 'message' in request.data.keys():
		message = request.data['message']

	status = request.data['status']
	new_election = Election.objects.create(
		name=request.data['name'],
		creator=user,
		passcode=passcode,
		status=status,
		start_date=request.data['start_date'],
		end_date=request.data['end_date'],
		message = message
	)

	if not new_election:
		return JsonResponse({'success': False, 'error': 'Election could not be created'})

	return JsonResponse({'election_id': new_election.pk, 'passcode': passcode, 'success': True})


# POST request for creating a ballot for a given election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def CreateBallot(request):

	user = User.objects.get(pk=request.user.pk)

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	if election.creator != user:
		return JsonResponse({'success': False, 'error': 'Authenticated user is not the election creator'})
	
	try:
		is_light = request.data['is_light']
		election.message = is_light
		election.save()
	except:
		return JsonResponse({'success': False, 'error': 'is_light is not set'})

	try:
		for ballot_item in request.data['ballot_items']:

			new_ballot_item = BallotItem.objects.create(
				election=election,
				question=ballot_item['question']
			)

			if not new_ballot_item:
				return JsonResponse({'success': False, 'error': 'Ballot item could not be created'})

			for ballot_item_choice in ballot_item['choices']:

				new_ballot_item_choice = BallotItemChoice.objects.create(
					ballot_item = new_ballot_item,
					answer=ballot_item_choice
				)

				if not new_ballot_item_choice:
					return JsonResponse({'success': False, 'error': 'Ballot item choice could not be created'})
	except:
		return JsonResponse({'success': False, 'error': 'Error creating ballot'})

	return JsonResponse({'success': True})


# POST request for changing the activity status of an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def GoLive(request):

	user = User.objects.get(pk=request.user.pk)

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	if election.creator != user:
		return JsonResponse({'success': False, 'error': 'Authenticated user is not the election creator'})

	election.status = (request.data['live'] == "true")
	election.save()

	return JsonResponse({'success': True, 'live': True})


# Returns all elections that a host has made
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def ViewElections(request):

	user = User.objects.get(pk=request.user.pk)

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
		electionDict['max_voters'] = election.max_voters
		electionDict['email_domain'] = election.email_domain
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

	serializer = UserSerializer(data=request.data)
	if serializer.is_valid():
		user = serializer.save()
		if user:
			return JsonResponse(serializer.data)

	return JsonResponse(serializer.errors)

@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated,))
def DeleteElection(request):

	try:
		election = Election.objects.filter(pk=request.data['election_id'])
		election.delete()
	except:
		return JsonResponse({'error': 'Please send election_id'})

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
def CanViewElectionResults(request):

	try:
		election_id = request.GET.get('election_id')
	except:
		return JsonResponse({'error': 'Please send election_id'})

	can_view = False

	try:
		election = Election.objects.get(pk=election_id)
		user_elections = VoterToElection.objects.filter(election=election, voter=request.user)
		can_view = len(user_elections) != 0

	except:
		return JsonResponse({'can_view': False})

	return JsonResponse({'can_view': can_view})


# POST request for changing the activity status of an election
@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def Notify(request):

	user = User.objects.get(pk=request.user.pk)

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	voters = VoterToElection.objects.filter(election=election)
	for voter in voters:
		msg = "Subject: The Results Are In!\n\nThe results are in for " + election.name + ".\n Login to eLect to view them."
		sendMail(voter.voter.email, msg)

	return JsonResponse({'success': True, 'live': True})


# POST request for registering for an election
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def GetMessage(request):

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'error': 'Election not found, make sure election_id is sent correctly.'})

	return JsonResponse({'message': election.message})

# POST request for registering for an election
@csrf_exempt
@api_view(['GET'])
@permission_classes((IsAuthenticated, ))
def IsPublic(request):

	try:
		election = Election.objects.get(pk=request.data['election_id'])
		return JsonResponse({'public': election.status})
	except:
		return JsonResponse({'error': 'Election not found, make sure election_id is sent correctly.'})



@csrf_exempt
@api_view(['POST'])
@permission_classes((IsAuthenticated, ))
def AddElectionRestrictions(request):

	try:
		election = Election.objects.get(pk=request.data['election_id'])
	except:
		return JsonResponse({'success': False, 'error': 'Election not found, make sure election_id is sent correctly.'})

	if 'max_voters' in request.data.keys() and request.data['max_voters'] > 0:

		try:
			max_voters = int(request.data['max_voters'])
		except:
			return JsonResponse({'success': False, 'error': 'max_voters must be a valid integer'})

		election.max_voters = max_voters
		election.save()
		
		# generate max_voters tokens and email them to host
		keys = random.sample(range(1, 999999), election.max_voters)
		for key in keys:
			new_key = ElectionKey.objects.create(
				election_id = election.pk,
				key = key
			)

		sendMail(election.creator.email, "Subject: Your Keys\n\nSend each voter one of these private passcodes to give them access to vote in your election\n\n" + ', '.join(str(e) for e in keys))

	try:
		if 'email_domain' in request.data.keys() and request.data['email_domain'] != '':
			election.email_domain = request.data['email_domain']
			election.save()
	except:
		return JsonResponse({'success': False, 'error': 'Invalid email domain'})

	return JsonResponse({'success': True})


def canUserVote(user, election):

	if DEBUG:
		return

	time = datetime.now()
	if time < datetime.strptime(election.start_date, '%Y-%m-%d %H:%M:%S') or time > datetime.strptime(election.end_date, '%Y-%m-%d %H:%M:%S'):
		return JsonResponse({'success': False, 'error': 'This election is not live yet'})

	try:
		is_user_registered = RegisterLink.objects.filter(election=election)
		is_user_registered = is_user_registered.filter(participant=user)[0]
	except:
		return JsonResponse({'success': False, 'error': 'This user is not resisted in this election'})

	try:
		didUserVote = VoterToElection.objects.filter(voter=user)
		didUserVote = didUserVote.filter(election=election)[0]
		return JsonResponse({'success': False, "error": "This user has already voted in this election!"})
	except:
		pass

def isElectionLive(election):
	if election.start_date == '':
		return False

	time = datetime.now()
	if time < datetime.strptime(election.start_date, '%Y-%m-%d %H:%M:%S') or time > datetime.strptime(election.end_date, '%Y-%m-%d %H:%M:%S'):
		return False
	return True


def send_vote_reminder():

	elections = Election.objects.all()

	for election in elections:

		end_date_str = election.end_date.split(' ')[0].split('-')

		today = datetime.today()
		if not (today.year == int(end_date_str[0]) and today.month == int(end_date_str[1]) and today.day == int(end_date_str[2])):
			continue

		msg = "Subject: Election " + election.name + " Ending Soon!\n\nMake sure to login to eLect today to cast your vote before the election closes."

		registered_voters = RegisterLink.objects.filter(election=election)
		for voter in registered_voters:

			if not VoterToElection.objects.filter(election=election, voter=voter.participant):

				try:
					sendMail(voter.participant.email, msg)
				except:
					continue



