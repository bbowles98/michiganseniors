# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.http import JsonResponse

from rest_framework.generics import RetrieveAPIView
from rest_framework import filters
from django.db import connection
from elect_api.serializers import ElectionSerializer
from elect_api.models import Election
# Create your views here.

class SearchViewSet(RetrieveAPIView):

	search_fields = ['name']
	filter_backends = (filters.SearchFilter,)
	serializer_class = ElectionSerializer
	queryset = Election.objects.all()

	def get_object(self):
		queryset = Election.objects.all()
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
	electionID = request.GET.get('id')
	return JsonResponse({'success': True, 'live': True})