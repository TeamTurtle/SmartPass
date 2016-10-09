#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import jinja2
import os
import httplib, urllib, base64
import json

from google.appengine.ext import db
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext.blobstore.blobstore import BlobReferenceProperty
from google.appengine.api.images import get_serving_url
from systemdb import *

JINJA_ENVIRONMENT = jinja2.Environment(loader = jinja2.FileSystemLoader(os.path.dirname(__file__) + "/templates"), autoescape = True)

class HostEventHandler(webapp2.RequestHandler):
    def get(self):
        template = JINJA_ENVIRONMENT.get_template('Create_Person_Group.html')
        self.response.write(template.render())

    def post(self):
        eventName = self.request.get("event1")
        eventDescription = self.request.get("eventDescription")

        event = personGroups(groupName = eventName, groupDescription = eventDescription)
        event.put()

        self.response.write(event.key().id_or_name())

class MainHandler(webapp2.RequestHandler):
    def get(self):
        template = JINJA_ENVIRONMENT.get_template('Homepage.html')
        self.response.write(template.render())

class BookEventHandler(webapp2.RequestHandler):
    def get(self):
        upload_url = blobstore.create_upload_url('/upload_photo')
        template = JINJA_ENVIRONMENT.get_template('Reserve_Seat.html')
        self.response.write(template.render({'url':upload_url}))

    def post(self):
        guestName = self.request.get('name')
        eventId = int(self.request.get('eventgroup'))
        guestWord = self.request.get('word')
        guestId = self.request.get('faceId')
        x = person(personId = guestId, personName = guestName, personKeyword = guestWord, eventId = eventId)
        x.put()

class PersonHandler(webapp2.RequestHandler):
    def get(self):
        personId = self.request.get('personId')
        personGroupId = self.request.get('personGroupId')
        person = db.GqlQuery("select * from person where personId = '%s' and eventId = %s" %(personId, personGroupId)).get()
        self.response.headers['Content-Type'] = 'application/json'
        obj = {
            'name': person.personName,
            'word': person.personKeyword,
          }
        self.response.out.write(json.dumps(obj))


app = webapp2.WSGIApplication([
    ('/', MainHandler),
    ('/hostevent', HostEventHandler),
    ('/bookevent', BookEventHandler),
    ('/getuser', PersonHandler)
], debug=True)
