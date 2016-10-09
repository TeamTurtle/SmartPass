from google.appengine.ext import db
from google.appengine.ext import ndb
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext.blobstore.blobstore import BlobReferenceProperty
from google.appengine.api.images import get_serving_url

class personGroups(db.Model):
    groupName = db.StringProperty()
    groupDescription= db.StringProperty()

class person(db.Model):
    personId = db.StringProperty()
    personName = db.StringProperty()
    personKeyword = db.StringProperty()
    eventId = db.IntegerProperty()

class pictures(db.Model):
    files = blobstore.BlobReferenceProperty(blobstore.BlobKey, required = True)
