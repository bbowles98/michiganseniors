from rest_framework import serializers
from elect_api.models import Election

class ElectionSerializer(serializers.Serializer):

	class Meta:
		model = Election
		fields = ['name', 'creator', 'passcode', 'status']
