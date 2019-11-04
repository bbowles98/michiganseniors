"""django_project URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.11/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.conf.urls import url
from django.contrib import admin
from rest_framework_jwt.views import obtain_jwt_token, refresh_jwt_token
from elect_api import views

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url('search/', views.SearchViewSet),
    url('register/', views.Register),
    url('vote/', views.Vote),
    url('cast/', views.Cast),
    url('results/', views.ViewResults),
    url('election/', views.CreateElection),
    url('ballot/', views.CreateBallot),
    url('live/', views.GoLive),
    url('elections/', views.ViewElections),
    url('signup/', views.CreateAccount),
    url('login/', obtain_jwt_token, name='login'),
    url('login-refresh/', refresh_jwt_token, name='login-refresh'),
]
