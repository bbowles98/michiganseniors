from rest_framework import serializers

class ElectionSerializer(serializers.Serializer):

	class Meta:
		model = Election
		fields = ('name', 'creator', 'passcode', 'status')
