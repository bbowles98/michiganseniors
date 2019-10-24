# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import JsonResponse

from rest_framework import viewsets
# Create your views here.

class SearchViewSet(viewsets.ModelViewSet):

	def get_queryset(self):
	# 	query = self.request.GET.get('search')
		queryset = Election.objects.all()
	# 	elections = []
	# 	for election in queryset :
	# 		if query in election.name:
	# 			elections.append(election)
		return queryset

def ViewResults(request):

	return JsonResponse({'results':[10, 9, 8]})

def Register(request):

	return JsonResponse({'success': True})
	
def Vote(request):

	return JsonResponse({'success': True})

def CreateElection(request):

	return JsonResponse({'election_id': 1, 'success': True})

def CreateBallot(request):
	return JsonResponse({'success': True})

def GoLive(request):
	return JsonResponse({'success': True, 'live': True})