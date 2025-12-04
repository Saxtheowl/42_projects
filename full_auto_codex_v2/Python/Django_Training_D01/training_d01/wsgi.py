"""
WSGI config for training_d01 project.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "training_d01.settings")

application = get_wsgi_application()
